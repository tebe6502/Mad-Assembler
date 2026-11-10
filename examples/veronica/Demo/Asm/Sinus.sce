//*************************************************************************************************************************************************************

function [out_list] = make_sinus_list(num_steps, num_sub_steps, scale) 
  out_list=list()
  
  for i=1:num_sub_steps
    angle = ((i - 1) * 2.0 * %pi) / num_steps
    out_list($+1) = sin(angle)*scale
  end
endfunction

//*************************************************************************************************************************************************************

function [integer_list] = convert_to_integer_list(float_list) 
  integer_list=list()
  for i=1:size(float_list)
    integer_list($+1) = int16(floor(float_list(i)(1)+0.0))
  end
endfunction

//*************************************************************************************************************************************************************

function  write_integer_list(integer_list, filename1)
  // low order bytes first
  fp = mopen(filename, 'wb')
  for i=1:size(integer_list)
    mput(modulo(integer_list(i), 256), 'uc', fp)
  end
  
  // high order bytes
  for i=1:size(integer_list)
    mput(integer_list(i)/256, 'uc', fp)
  end
  mclose(fp)
endfunction
 
//*************************************************************************************************************************************************************

function main(num_steps, num_sub_steps, scale, filename) 
  float_list = make_sinus_list(num_steps, num_sub_steps, scale)
  integer_list = convert_to_integer_list(float_list)
  write_integer_list(integer_list, filename)
endfunction

//*************************************************************************************************************************************************************

main(256, 128, 32768, 'AbsSinus8000.dat')

//*************************************************************************************************************************************************************
