use rand::Rng;
use sodiumoxide::crypto::onetimeauth;


pub struct TestcasePoly1305{
    pub variables: Vec<String>,
    pub expected_result: [u8;16],
}

pub fn generate_testcase() -> TestcasePoly1305{
    let mut rng = rand::thread_rng();

    let messagelen: usize = 131;//rng.gen_range(131, 200);
    let mut message: [u8; 256] = [0; 256];
    rng.fill(&mut message);

    let poly1305_key = onetimeauth::gen_key();
    let key = poly1305_key.0;

    //print variables
    let mut variables = Vec::new();

    let mut var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        static unsigned char c[{}] = {{", messagelen).as_str());

    for i in 0..messagelen - 1 {
        var.push_str(format!("0x{:x}, ", message[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", message[(messagelen - 1) as usize]).as_str());
    variables.push(var);

    var = String::with_capacity((messagelen*2) as usize);
    var.push_str(format!("        static unsigned char rs[32] = {{").as_str());
    for i in 0..31 {
        var.push_str(format!("0x{:x}, ", key[i as usize]).as_str());
    }
    var.push_str(format!("0x{:x}}};", key[31 as usize]).as_str());
    variables.push(var);

    let message_slice = &message[0..messagelen];

    let result = onetimeauth::authenticate(&message_slice, &poly1305_key).0;

    println!("{:02x?}", result);
    TestcasePoly1305 {variables, expected_result: result}

}