// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use base64::Engine;
use rand::{distributions::Standard, Rng};

use tauri::{
    api::process::{Command, CommandEvent},
    AppHandle, CustomMenuItem, GlobalWindowEvent, Manager, SystemTray, SystemTrayEvent,
    SystemTrayMenu,
};

const SERVER_ENDPOINT: &str = "http://127.0.0.1:3156";

fn main() {
    tauri_plugin_deep_link::prepare("dev.simple.run");

    let dashboard_menu_item = CustomMenuItem::new("dashboard", "Open Dashboard");
    let quit_menu_item = CustomMenuItem::new("quit", "Quit Simple Run");

    let menu = SystemTrayMenu::new()
        .add_item(dashboard_menu_item)
        .add_native_item(tauri::SystemTrayMenuItem::Separator)
        .add_item(quit_menu_item);

    let system_tray = SystemTray::new().with_menu(menu);

    tauri::Builder::default()
        .setup(|_app| {
            start_server();
            check_server_started();
            setup_deep_linking();
            Ok(())
        })
        .system_tray(system_tray)
        .on_system_tray_event(system_tray_event_handler)
        .on_window_event(window_event_handler)
        .run(tauri::generate_context!())
        .expect("Error while running Simple Run");
}

fn start_server() {
    tauri::async_runtime::spawn(async move {
        let (mut rx, mut _child) = Command::new_sidecar("desktop")
            .expect("Failed to setup `desktop` sidecar")
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

fn generate_secret_key_base() -> String {
    let random_bytes: Vec<u8> = rand::thread_rng().sample_iter(Standard).take(64).collect();
    base64::engine::general_purpose::STANDARD_NO_PAD.encode(random_bytes)
}

fn check_server_started() {
    let sleep_interval = std::time::Duration::from_millis(100);
    println!("Waiting for the server to start on {}...", SERVER_ENDPOINT);

    loop {
        let client = reqwest::blocking::Client::new();

        match client.get(format!("{}/healthz", SERVER_ENDPOINT)).send() {
            Ok(res) => {
                if res.status() == 200 {
                    break;
                }
            }
            Err(_) => {}
        }

        std::thread::sleep(sleep_interval);
    }
}

fn setup_deep_linking() {
    tauri_plugin_deep_link::register("simplerun", move |request| {
        check_server_started();

        let payload = serde_json::json!({
            "request": &request
        });

        let client = reqwest::blocking::Client::new();
        let _ = client
            .post(format!("{}/api/application", SERVER_ENDPOINT))
            .json(&payload)
            .send();
    })
    .unwrap();
}

fn system_tray_event_handler(app: &AppHandle, event: SystemTrayEvent) {
    match event {
        SystemTrayEvent::MenuItemClick { id, .. } => match id.as_str() {
            "dashboard" => {
                let window = app.get_window("main").unwrap();
                match window.is_visible() {
                    Ok(true) => {
                        let _ = window.set_focus();
                    }
                    Ok(false) => {
                        let _ = window.show();
                    }
                    Err(_) => unimplemented!("This case is not possible!"),
                }
            }
            "quit" => app.exit(0),
            _ => {}
        },
        _ => {}
    }
}

fn window_event_handler(e: GlobalWindowEvent) {
    match e.event() {
        tauri::WindowEvent::CloseRequested { api, .. } => {
            e.window().hide().unwrap();
            api.prevent_close();
        }
        _ => {}
    }
}
