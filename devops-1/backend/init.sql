-- Khởi tạo bảng và dữ liệu mẫu cho DevOps Training App
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO messages (content) VALUES
    ('Chào mừng bạn đến với khoá DevOps Training!')
ON CONFLICT DO NOTHING;
