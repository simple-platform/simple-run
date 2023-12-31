pub fn handle_run_request(request: String) {
    let possible_code = request.replace("simplerun://", "");
    let code = possible_code.trim();

    if code.is_empty() {
        return;
    }

    println!("!!! Run request received: {}", code);
}
