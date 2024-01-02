// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{
    api::process::{Command, CommandEvent},
    AppHandle, CustomMenuItem, GlobalWindowEvent, Manager, SystemTray, SystemTrayEvent,
    SystemTrayMenu,
};

const ERR_INVALID_CASE: &str = "This case is not possible!";

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
            .expect("failed to setup `desktop` sidecar")
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
    let host = "localhost".to_string();
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
                    Err(_) => unimplemented!("{}", ERR_INVALID_CASE),
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
