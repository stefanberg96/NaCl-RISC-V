use rand::Rng;


pub fn generate_testcase() -> Vec<String>{
    let mut rng = rand::thread_rng();
    let messagelen: u16 = 131;//rng.gen_range(131, 200);
    let mut message: [u8; 256] = [0; 256];
    rng.fill(&mut message);
    let mut key: [u8; 32] = [0; 32];
    rng.fill(&mut key);
    //print variables
    let mut m = Vec::new();

    let mut var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        unsigned char c[{}] = {{", messagelen).as_str());

    for i in 0..messagelen - 1 {
        var.push_str(format!("0x{:x}, ", message[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", message[(messagelen - 1) as usize]).as_str());
    m.push(var);

    var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        unsigned char rs[32] = {{").as_str());
    for i in 0..31 {
        var.push_str(format!("0x{:x}, ", key[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", key[31 as usize]).as_str());
    m.push(var);
    m
}