/*
 *  NuCrunch 0.1
 *  Christopher Jam
 *  February 2016
 */
use std::io;
use std::io::prelude::*;
use std::fs::File;
use std::path::Path;
use std::collections::HashMap;

macro_rules! optlog {
	( $log:expr, $($x:expr),* ) => { if let Some(ref mut f)=$log {let _ = writeln!(f,$($x,)*);} }
}

const MAX_RUN: usize = 255;

fn readbytes(fnam: &str) -> Result<Vec<u8>, io::Error> {

	let fnam = Path::new(fnam);
	println!("loading {}...", fnam.display());
	let mut f = try!(File::open(fnam));
	let mut buffer: Vec<u8> = Vec::with_capacity(32 * 200);

	try!(f.read_to_end(&mut buffer));
	Ok(buffer)
}

fn read_prg(fnam: &str) -> Result<(Vec<u8>, u16), io::Error> {
	let v = try!(readbytes(fnam));
	let data = v[2..v.len()].to_vec();
	let lb = v[0] as u16;
	let hb = v[1] as u16;
	Ok((data, lb + 256 * hb))
}

fn _writebytes(fnam: &str, data: Vec<u8>) -> Result<(), io::Error> {
	let path = Path::new(fnam);
	let display = path.display();

	let mut file = try!(File::create(&path));

	println!("Writing {:} bytes to {}...", data.len(),display);

	try!(file.write_all(&data[..]));
	Ok(())
}
fn write_prg(fnam: &str, addr: u16, data: Vec<u8>) -> Result<(), io::Error> {
	let path = Path::new(fnam);
	let display = path.display();

	let mut file = try!(File::create(&path));

	let addrv = [
		 (addr&0xff) as u8,
		 (addr>>8) as u8,
	];

	println!("Writing {:} bytes to {}...", 2+data.len(),display);
	try!(file.write_all(&addrv[..]));
	try!(file.write_all(&data[..]));
	Ok(())
}

type DecompressionCost = usize;
const MAX_COST:DecompressionCost = 1000000000;

fn sym_cost(_last_offset:usize, offset:usize, len: usize) -> DecompressionCost {
	(
	 if offset==0 {
	 encoding_costs::egl_k(len-1,0)+8*len
	 }
	 else {
	 assert!(len>=2);
	 encoding_costs::egl_k(len-2,0)+encoding_costs::new_ofse(offset-1)+1
	 }
	)as DecompressionCost
}

#[derive(Debug)]
struct Token {
	offset: usize,
	length: usize,
	cumulative_cost: DecompressionCost,
}

impl Token {
	fn new(predecessor: &Token, offset:usize, length: usize) -> Option<Token> {

		if
			(offset==0 && predecessor.offset>0) ||
			(offset==0 && predecessor.length>128) ||  //EXTENSION REQUIRED FOR THIS
			(offset>0 && length>=2)
		{
			let cost=predecessor.cumulative_cost+sym_cost(predecessor.offset, offset, length);
			Some(Token{
				offset:offset,
				length:length,
				cumulative_cost:cost,
			})
		}
		else {None}
	}
}

fn crunch(src: &Vec<u8>) -> Vec<Token> {
	let preflight_len = 32;

	let early_out=true;
	let preflight=true && (src.len()>preflight_len);

	let mut preflight_count = HashMap::new();

	let mut last_seen = HashMap::new();
	let mut tokens: Vec<Token>=Vec::with_capacity(src.len()+1);
	tokens.push(Token{offset:1, length:0, cumulative_cost:0});  // dummy head needs offset>0 to make starting run legal

	if preflight {
		for spf in 0..src.len()-preflight_len+1 {
			let key=&src[spf..spf+preflight_len];
			let count:usize = *(preflight_count.get(key).unwrap_or(&0))+1;
			preflight_count.insert(key,count);
		}
	}


	for target_len in 1..src.len()+1 {
		let mut best_match:Token = Token {offset:0, length:0, cumulative_cost:MAX_COST}; // this will be beaten

		let search_end = if target_len < MAX_RUN { target_len } else { MAX_RUN };
		let mut might_still_find_run_matches=true;
		let mut give_up_on_copies=false;

		for length in 1..search_end+1 {
			let run_start = target_len-length;

			let predecessor = &tokens[run_start];

			let key = &src[run_start..target_len];
			if preflight && length==preflight_len {
				let k:usize= *preflight_count.get(key).unwrap_or(&0);
				if k==0 {
					panic!("run_start = {}, src.len()={}, k=0",run_start,src.len());
				}
				assert!(k>=1);
				if k==1 {
					give_up_on_copies=true;
				}
			}

			if !give_up_on_copies {
				if might_still_find_run_matches || !early_out {
					if let Some(match_start) =  last_seen.get(key) {
						if let Some(candidate )= Token::new(predecessor, run_start-match_start, length) {
							if candidate.cumulative_cost<=best_match.cumulative_cost {
								best_match=candidate;
							}
						}
					}
					else {
						might_still_find_run_matches = false;
					}
				}
				last_seen.insert(key, run_start);
			}

			if let Some(candidate )= Token::new(predecessor, 0, length) {
				if candidate.cumulative_cost<=best_match.cumulative_cost {
					best_match=candidate;
				}
			}
		}
		assert!(best_match.cumulative_cost!=MAX_COST);
		tokens.push(best_match);
	}


	let mut result=Vec::<Token>::new();
	let mut endp=src.len();
	while endp>0 {
		let next=tokens.swap_remove(endp);
		endp-=next.length;
		result.push(next);
	}
	assert!(endp==0);
	result.reverse();
	result
}

mod encoding_costs {

	fn log2(mut v:usize) -> usize {
		let mut r     = if v > 0xFFFF {1usize<< 4} else {0}; v >>= r;
		let mut shift = if v > 0xFF   {1usize<< 3} else {0}; v >>= shift; r |= shift;
		shift         = if v > 0xF    {1usize<< 2} else {0}; v >>= shift; r |= shift;
		shift         = if v > 0x3    {1usize<< 1} else {0}; v >>= shift; r |= shift;
        r |( v >> 1)
	}
	pub fn egl_k(i:usize, k:usize) -> usize {
		let i = i>>k;
		log2(i+1)*2+1+k
	}
	pub fn new_ofse(i:usize) ->usize {
		let upper = i>>8;
		let bits_for_upper = egl_k(upper,0);

		if i<256 {
			bits_for_upper+egl_k(i&255,3)
		}
		else {
			bits_for_upper+8
		}
	}

}

struct BitStreamCursor {
	bits_written:usize,
	bits_index:usize,
	debug_str:String,
}
impl BitStreamCursor {
	fn new(debug_str:&str) -> BitStreamCursor {
		BitStreamCursor {
			bits_written:8,
			bits_index:0,
			debug_str:debug_str.to_string(),
		}
	}
}

struct Encoder {
	encoded_stream:Vec<u8>,
	single:BitStreamCursor,
	pairs:BitStreamCursor,
	nibbles:BitStreamCursor,

	last_symbol_was_copy:bool,
	first_symbol:bool,
	target_addr:u16,
	reverse:bool,

	bit_count:usize,  // purely for instrumenting encode costs
	log:Option<File>,
	start_addr:u16,
}


impl Encoder {

	fn new(log:Option<File>, start_address:u16, reverse:bool) -> Encoder {
		Encoder {
			encoded_stream: Vec::new(),
			single:BitStreamCursor::new(" "),
			pairs:BitStreamCursor::new("\\/"),
			nibbles:BitStreamCursor::new("|T||"),
			last_symbol_was_copy:false,
			first_symbol:true,
			target_addr:0,
			reverse:reverse,
			bit_count:0,
			log:log,
			start_addr:start_address,
		}
	}
	fn _push_byte (&mut self, b:u8) {
		self.encoded_stream.push(b);
	}
	fn push_byte (&mut self, b:u8) {
		optlog!(self.log,"{:04x}  : {:02x}",self.encoded_stream.len()+(self.start_addr as usize),b);
		self._push_byte(b);
		self.bit_count+=8;
	}
	fn push_word (&mut self, w:u16) {
		self.push_byte( (w&0xff) as u8);
		self.push_byte( (w>>8) as u8);
	}
	fn push_bit         (&mut self, b:u8) { self.push_bit_to_stream(b, 1) }
	fn push_pair_bit    (&mut self, b:u8) { self.push_bit_to_stream(b, 2) }
	//fn push_nibble_bit  (&mut self, b:u8) { self.push_bit_to_stream(b, 4) }

	fn push_bit_to_stream  (&mut self, b:u8, sid:usize) {
		let ref mut stream = match sid {
			1=>&mut self.single,
			2=>&mut self.pairs,
			4=>&mut self.nibbles,
			_ => panic!("undefined stream")
			};

		if stream.bits_written==8 {
			stream.bits_index=self.encoded_stream.len();
			self.encoded_stream.push(b<<7);
			stream.bits_written=1;
		}
		else {
			self.encoded_stream[stream.bits_index]+=b*(128>>stream.bits_written);
			stream.bits_written+=1;
		}
		optlog!(self.log,"{:04x}.{}: {:}{:x}",
			stream.bits_index+(self.start_addr as usize),
			8-stream.bits_written,
			&stream.debug_str[{let j=stream.bits_written%stream.debug_str.len();j..j+1}],
			b);
		self.bit_count+=1;
	}



    fn push_interleaved_exp_golom_k(&mut self, x:u16, k:i32, all_pairs:bool, nibble_wrapped:bool) {
        let remainder=x%(1<<k);
        let mut head=(x>>k)+1;
        let mut bits:Vec<u8>=Vec::new();
        while head>0 {
            bits.push((head%2) as u8);
            head=head>>1;
		}
        bits.pop();  //last 1 is implicit

		let headstream =
			if nibble_wrapped { 4 }
			else if all_pairs { 2 }
			else              { 1 };

        if bits.len()==0 {
			self.push_bit_to_stream(0,headstream);
		}
        else {
			self.push_bit_to_stream(1,headstream);

            while let Some(nextbit)=bits.pop() {
                self.push_pair_bit(nextbit);
                self.push_pair_bit(if bits.len()>0 {1} else{0});
			}
		}
		if nibble_wrapped {
			assert!(k%4==3)
		}
        for i in 0..k {
			let stream =
				if nibble_wrapped {4}
				else if i<(k-k%2) || all_pairs {2}
				else {1};
			self.push_bit_to_stream(( (remainder>>(k-i-1))%2) as u8, stream);
		}
	}

	fn new_segment(&mut self, target_addr:u16) {
		self.push_word( target_addr);
		optlog!(self.log, "Segment address: {:04x}", target_addr);
		self.first_symbol=true;
		self.last_symbol_was_copy=false;
		self.target_addr=target_addr;
	}
	fn encode_literal(&mut self, data:&[u8]) {
		if self.last_symbol_was_copy {
			self.push_bit(0);
		}
		else {
			if !self.first_symbol {
				let target_addr=self.target_addr;  //preserve what target was before ivar is disturbed by the marker encoding
				self.encode_copy(256,2);  //length 256 to terminate segment, offset of 2 to continue/1 to stop
				self.new_segment(target_addr);
			}
		}
		let length = data.len();
		assert!(length<256);
		self.push_interleaved_exp_golom_k((length-1) as u16,0,false, false);
		for d in data {
			self.push_byte(*d);
		}
		optlog!(self.log, "           {:04x} ({:02x} {:04x}) {:}", self.target_addr, length, 0, {
				let hd:Vec<String>=data.iter().map(|x| format!("{:02x}",x)).collect();
				hd.join(" ")
				});
        self.last_symbol_was_copy=false;
        self.first_symbol=false;
		if self.reverse {
			self.target_addr-=length as u16;
		}
		else {
			self.target_addr+=length as u16;
		}
	}
	fn encode_copy(&mut self, length:usize, offset:usize) {
		if self.last_symbol_was_copy {
			self.push_bit(1);
		}
        assert!(offset>=1);
		let enc_offset=offset-1;
        let oh=(enc_offset>>8) as u8;
        let ol=(enc_offset&0xff) as u8;

        self.push_interleaved_exp_golom_k(oh as u16,0,true, false);
        if oh>0 {
            self.push_byte(ol);
			}
        else {
            self.push_interleaved_exp_golom_k(ol as u16,3, false, true);
		}
		assert!(length>=2);
        self.push_interleaved_exp_golom_k((length-2) as u16,0,true, false);

		if length<256 {
			optlog!(self.log, "           {:04x} ({:02x} {:04x})", self.target_addr, length, offset);
		}

        self.last_symbol_was_copy=true;
        self.first_symbol=false;
		if self.reverse {
			self.target_addr-=length as u16;
		}
		else {
			self.target_addr+=length as u16;
		}
	}
}


struct InputSpec {
	file_name:String,
	end_of_group:bool,
}
enum Location {
	Start(u16),
	End(u16),
	None,
}
struct Conf {
	input_fn_list: Vec<InputSpec>,
	output_fn: String,
	reverse: bool,
	load_location: Location,
	log_fn: Option<String>,
}

fn usage() {
	use std::env::args;
	writeln!(&mut std::io::stderr(),
		"Usage:\n\t{} input.prg [input2.prg ...] [-r] -o output.prg [-l 0xload_start| -e 0xload_end] [-L dump.log]\n",
		&args().nth(0).unwrap()).unwrap();
	writeln!(&mut std::io::stderr(),
		" -r\toutput for rdecrunch (unpacks from high to low)\n").unwrap();
	writeln!(&mut std::io::stderr(),
		" Use commas to delineate groups, eg\n\t{} f1g1.prg f2g1.prg, f1g2.prg, f1g3,prg f2g3.prg f3g3.prg -o out.prg -l 0x1000", 
		&args().nth(0).unwrap()).unwrap();
	writeln!(&mut std::io::stderr(),
		" Call decrunch to unpack the first group, then decrunch_next_group for each subsequent group\n",
		).unwrap();
}

fn parse_u16(arg: &str) -> Result<u16, std::num::ParseIntError> {
	if arg.len()>2 && &arg[..2]=="0x" {
		u16::from_str_radix(&arg[2..],16)
	}
	else {
		u16::from_str_radix(arg,10)
	}
}


fn parse_args() -> Result<Conf,String> {
	use std::env::args;
	let args:Vec<_> = args().collect();

	let mut output_fn:Option<String> = None;
	let mut input_fn_list  = Vec::<InputSpec>::new();
	let mut load_location:Location   = Location::None;
	let mut log_fn:Option<String>    = None;
	let mut reverse = false;

	let mut d=args.iter();
	d.next();
	while let Some(x) = d.next() {
		match x.as_ref() {

			"-o" => output_fn = {
				if let Some(op)=d.next() {
					Some(op.clone())
				}
				else {
					return Err("no output file name following -o".to_string());
				}
			},
			"-r" => {
					reverse=true;
			},

			"-L" => log_fn = {
				if let Some(op)=d.next() {
					 Some(op.clone())
				}
				else {
					return Err("no log filename following -L".to_string());
				}
			},

			"-l" => {
				if let Some(la)=d.next() {
					if let Ok(addr)=parse_u16(la) {
						load_location = Location::Start(addr);
					}
					else {
						return Err("failed to parse load address".to_string());
					}
				}
				else {
					return Err("no load address following -l".to_string());
				}
			},

			"-e" => {
				if let Some(la)=d.next() {
					if let Ok(addr)=parse_u16(la) {
						load_location = Location::End(addr);
					}
					else {
						return Err("failed to parse load address".to_string());
					}
				}
				else {
					return Err("no load address following -l".to_string());
				}
			},

				_ =>{
					let mut x=x.clone();
					let spec=
					match x.pop().unwrap() {
						',' => {
							InputSpec{file_name: x, end_of_group: true}},
						e   => {x.push(e);
							InputSpec{file_name: x, end_of_group: false}},
					};
					input_fn_list.push(spec);
				},
		}
	}
	match input_fn_list.pop(){
		None => return Err("no input files specified".to_string()),
		Some(group_end) => input_fn_list.push(InputSpec{file_name:group_end.file_name,end_of_group:true}),
	}

	if let Some(output_fn)=output_fn {
		Ok(Conf{
			input_fn_list:  input_fn_list,
			output_fn:      output_fn,
			reverse:        reverse,
			load_location: load_location,
			log_fn: log_fn,
		})
	}
	else {
		return Err("no output file specified".to_string());
	}
}




fn main() {
	match parse_args() {
		Err(e)=> {
			writeln!(&mut std::io::stderr(), "error {}", e).unwrap();
			usage();
		},
		Ok(conf)=> {

			let log = conf.log_fn.and_then(|path| match File::create(&path) { Ok(x) => Some(x), _ => None});

			let log_addr = match conf.load_location {
				Location::Start(addr) =>addr,
				Location::End(_) =>0,
				Location::None =>  {usage(); return}
			};

			let mut e=Encoder::new(None, log_addr, conf.reverse);

			e.log=log;
			optlog!(e.log, "producing {}", conf.output_fn);
			optlog!(e.log, "Load address: {:04x}", log_addr);

			print!("producing {}, ", conf.output_fn);
			println!("for load address 0x{:04x}", log_addr);

			for input_spec in conf.input_fn_list.iter() {
				let (mut buffer, target_addr) = match read_prg(&input_spec.file_name[..]) {
					Ok(x) => x,
					Err(e) => panic!("Failed with {}", e),
				};
				println!("crunching 0x{:04x} bytes with target address of 0x{:04x}", buffer.len(), target_addr);

				if conf.reverse {
					buffer.reverse();
					e.new_segment( target_addr + (buffer.len() - 1) as u16 );
				}
				else {
					e.new_segment( target_addr);
				}

				let tokens = crunch(&buffer);

				let mut addr=0;
				for t in tokens {
					if t.offset==0 {
						let literal = &buffer[addr..addr+t.length];
						e.encode_literal(literal);
					}
					else {
						e.encode_copy(t.length, t.offset);
					}

					addr+=t.length;
				}
				println!("segment ends at 0x{:04x}",e.target_addr);
				if input_spec.end_of_group {
					e.encode_copy(256,1);  //length 256 to terminate segment, offset of 2 to continue/1 to stop
					println!("ending group\n");
				}
				else {
					e.encode_copy(256,2);  //length 256 to terminate segment, offset of 2 to continue/1 to stop
					println!("continuing group\n");
				}
			}

			let load_addr = match conf.load_location {
				Location::Start(addr) => addr,
				Location::End(e_addr) => e_addr-(e.encoded_stream.len() as u16),
				Location::None => panic!("no location, but this should already have been handled")
			};
			if conf.reverse {
				e.encoded_stream.reverse();
			}
			match write_prg(&conf.output_fn[..], load_addr, e.encoded_stream) {
				Ok(()) => println!("Done."),
				Err(e) => panic!("Failed with {}", e),
			}
		},
	}
}
