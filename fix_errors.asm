.extern transpose_data_chunk
.global isCorrect, find_index_of_errored_row, fix_data_block

.data

.text
isCorrect:
  # rdi holds the data byte
  # r8 holds the current count of ones
  # rax holds the result
  
  xor %r8, %r8
  xor %rax,%rax
  mov $8, %rcx
  mov $1,%r9
  xor %rdx,%rdx

count:
  test $1,%dil
  je close
  inc %r8

close:
  shr %dil
  loop count
  
  test $1,%r8
  cmove %r9,%rax 
  ret

find_index_of_errored_row:
  xor %rcx, %rcx # loop counter
  xor %r9,%r9 # err'd lines
  xor %r8,%r8 # last incorrect index
  movq $-1,(%rsi)
err_count_loop:
  # prologue 
dbg_1:
  push %rdi
  push %rcx
  push %r9
  push %r8
  push %rsi
  movb (%rdi),%dil
  callq isCorrect

  # epilogue
  pop %rsi
  pop %r8
  pop %r9 
  pop %rcx
  pop %rdi  
  inc %rdi # should i increase by 1 or by 8? needs testing
dbg_2:
  xor $1,%rax
  add %rax,%r9
  cmp $0,%rax
  je cont 
set_mem:
  mov %rcx,(%rsi)
cont:  
  inc %rcx
  cmp $7,%rcx
  jl err_count_loop

end: 
  mov %r9, %rax
  ret
  
  
fix_data_block:
  push %rbp
  mov %rsp, %rbp
  sub $16, %rsp
  push %rdi
  push %rsi
  push %rdx
  lea -16(%rbp), %rsi # out pointer location for bad line index 
  
  # find the row that was damaged
  callq find_index_of_errored_row
  cmp $0,%rax
  je end_no_err

  cmp $2,%rax
  jge end_fail
  push %rbx
  mov (%rsi),%rbx # rbx contains the row of the err'd data
  mov -24(%rbp), %rdi # actual normal matrix
  mov $8,%rsi # size of transposed matrix
  lea -8(%rbp), %rdx # pointer to the empty space for the transpose matrix
  callq transpose_data_chunk

  # find the column that was damaged
  lea -8(%rbp),%rdi # set pointer of transposed matrix into the first param
  lea -16(%rbp), %rsi # set pointer of out damagd column index into the second param
  callq find_index_of_errored_row

  cmp $2,%rax
  jge end_fail

  mov (%rsi), %rsi # rsi contains the column of the err'd data
  mov -24(%rbp), %rdi # actual normal matrix

  sub $7,%rsi # fix index of damaged column to be from the right side up
  neg %rsi

  mov %rsi,%rcx # move column shift into the shift register
    
  mov $1,%r11
  shl %cl,%r11 # create appropriate bit mask

  add %rbx,%rdi
  mov (%rdi),%rcx
  xor %r11,%rcx # apply mask
  
  mov %rcx,(%rdi) # write to memory

end_fixed:
  mov $2,%rax
  jmp out_end
end_fail:
  mov $0,%rax
  jmp out_end
end_no_err:
  mov $1,%rax
out_end:
  pop %rbx
  pop %rdx
  pop %rsi
  pop %rdi
  leave
  ret

