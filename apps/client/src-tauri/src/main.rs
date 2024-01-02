// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
use base64::Engine;
use rand::{distributions::Standard, Rng};
use tauri::api::process::{Command, CommandEvent};

fn generate_secret_key_base() -> String {
    let random_bytes: Vec<u8> = rand::thread_rng().sample_iter(Standard).take(64).collect();
    base64::engine::general_purpose::STANDARD_NO_PAD.encode(random_bytes)
}

fn main() {
    tauri::Builder::default()
        .setup(|_app| {
            start_server();
            check_server_started();
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("Error while running Simple Run");
}
fn start_server() {
    tauri::async_runtime::spawn(async move {
        let (mut rx, mut _child) = Command::new_sidecar("desktop")
            .expect("failed to setup `desktop` sidecar")
            .args(["--client", &generate_secret_key_base()])
            .spawn()
            .expect("Failed to spawn packaged node");

        while let Some(event) = rx.recv().await {
            if let CommandEvent::Stdout(line) = event {
                println!("{}", line);
            }
        }
    });
}

fn check_server_started() {
    let sleep_interval = std::time::Duration::from_millis(200);
    let host = "127.0.0.1".to_string();
    let port = "5000".to_string();
    let addr = format!("{}:{}", host, port);
    println!(
        "Waiting for your phoenix dev server to start on {}...",
        addr
    );
    loop {
        if std::net::TcpStream::connect(addr.clone()).is_ok() {
            break;
        }
        std::thread::sleep(sleep_interval);
    }
}
