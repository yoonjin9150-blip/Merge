//
//  BoardCell.swift
//  Merge
//
//  머지 보드에서 사용하는 행·열 주소입니다.
//

import Foundation

enum BoardCellState: String, Codable {
    // 아직 공개되지 않아 아이템을 보거나 칸을 사용할 수 없습니다.
    case sealed

    // 미리 정해진 아이템이 바위에 막혀 있습니다.
    case rockBlocked

    // 일반 아이템의 생성·이동·머지가 가능한 칸입니다.
    case open
}

struct BoardCell: Hashable, Codable {
    let column: Int
    let row: Int
}
