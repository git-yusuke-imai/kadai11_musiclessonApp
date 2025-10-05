//
//  AuthView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/12.
//

// ファイル: Views/Auth/AuthView.swift
import SwiftUI

struct AuthView: View {
    @StateObject private var vm = AuthViewModel()
    
    var body: some View {
        
        ZStack {
            AppBackgroundView()   // ← グリーン背景を背面に敷く}
            VStack {
                // デバッグ用表示（これが出るかでクラッシュかどうか切り分け）
                Text("DEBUG: AuthView 表示中")
                    .foregroundColor(.blue)
                
                VStack(spacing: 24) {
                    Text(vm.mode == .login ? "Welcome" : "アカウント作成")
                        .font(.largeTitle).bold()
                    
                    VStack(spacing: 12) {
                        TextField("メールアドレス", text: $vm.email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("パスワード（6文字以上）", text: $vm.password)
                            .textFieldStyle(.roundedBorder)
                        
                        if vm.mode == .signup {
                            Picker("権限", selection: $vm.role) {
                                Text("生徒").tag("student")
                                Text("講師").tag("teacher")
                                Text("管理者").tag("admin")
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    if let err = vm.errorMessage {
                        Text(err).foregroundColor(.red).font(.footnote)
                    }
                    
                    Button {
                        Task { await vm.submit() }
                    } label: {
                        HStack {
                            if vm.loading { ProgressView() }
                            Text(vm.mode == .login ? "ログイン" : "登録")
                                .bold()
                                .foregroundColor(AppTheme.bgTop)  // ← 明るい青を指定
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                            .background(Color.white.opacity(0.15)) // ← 薄く背景
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1.5) // ← 白枠ぼかし
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    //.buttonStyle(.borderedProminent)
                    .disabled(vm.loading)
                    
                    Button {
                        withAnimation {
                            vm.mode = (vm.mode == .login) ? .signup : .login
                        }
                    } label: {
                        Text(vm.mode == .login ? "新規登録はこちら" : "既にアカウントをお持ちの方はこちら")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: 420)
            }
        }
    }
}
