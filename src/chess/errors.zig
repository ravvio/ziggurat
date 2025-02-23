pub const ChessError = error{
    InvalidPieceString,
    InvalidPromotionPiece,
    InvalidMove,
    InvalidAlgebraicSquare,
    NonPseudolegalMove,
};
