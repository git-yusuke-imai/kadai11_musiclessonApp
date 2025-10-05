//
//  AnyEncodable.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/19.
//

import Foundation

/// 任意の Encodable を箱詰めする薄いラッパー
public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ value: T) { self._encode = value.encode }
    public func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
