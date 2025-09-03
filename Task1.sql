CREATE DATABASE library_management;
USE library_management;

CREATE TABLE Books (
    BOOK_ID INT PRIMARY KEY AUTO_INCREMENT,
    TITLE VARCHAR(100) NOT NULL,
    AUTHOR VARCHAR(100) NOT NULL,
    GENRE VARCHAR(50),
    YEAR_PUBLISHED INT,
    AVAILABLE_COPIES INT DEFAULT 0,
    CHECK (YEAR_PUBLISHED <= 2024),
    CHECK (AVAILABLE_COPIES >= 0)
);
CREATE TABLE Members (
    MEMBER_ID INT PRIMARY KEY AUTO_INCREMENT,
    NAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL,
    PHONE_NO VARCHAR(15),
    ADDRESS TEXT,
    MEMBERSHIP_DATE DATE NOT NULL
);

CREATE TABLE BorrowingRecords (
    BORROW_ID INT PRIMARY KEY AUTO_INCREMENT,
    MEMBER_ID INT NOT NULL,
    BOOK_ID INT NOT NULL,
    BORROW_DATE DATE NOT NULL,
    RETURN_DATE DATE,
    FOREIGN KEY (MEMBER_ID) REFERENCES Members(MEMBER_ID),
    FOREIGN KEY (BOOK_ID) REFERENCES Books(BOOK_ID),
    CHECK (RETURN_DATE IS NULL OR RETURN_DATE >= BORROW_DATE)
);


INSERT INTO Books (TITLE, AUTHOR, GENRE, YEAR_PUBLISHED, AVAILABLE_COPIES) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 3),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 2),
('1984', 'George Orwell', 'Science Fiction', 1949, 4),
('Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 3),
('The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 5),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 'Fantasy', 1997, 6),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 1951, 2),
('The Da Vinci Code', 'Dan Brown', 'Mystery', 2003, 4),
('The Alchemist', 'Paulo Coelho', 'Fiction', 1988, 3),
('The Lord of the Rings', 'J.R.R. Tolkien', 'Fantasy', 1954, 4);




INSERT INTO Members (NAME, EMAIL, PHONE_NO, ADDRESS, MEMBERSHIP_DATE) VALUES
('John Doe', 'john@email.com', '1234567890', '123 Main St, City1', '2024-01-01'),
('Jane Smith', 'jane@email.com', '0987654321', '456 Oak Ave, City2', '2024-02-15'),
('Robert Johnson', 'robert@email.com', '5555555555', '789 Pine Rd, City3', '2024-01-20'),
('Mary Williams', 'mary@email.com', '4444444444', '321 Elm St, City1', '2024-03-01'),
('James Brown', 'james@email.com', '3333333333', '654 Maple Dr, City2', '2024-02-01'),
('Sarah Davis', 'sarah@email.com', '2222222222', '987 Cedar Ln, City3', '2024-01-15'),
('Michael Wilson', 'michael@email.com', '1111111111', '147 Birch Ave, City1', '2024-03-15'),
('Elizabeth Taylor', 'elizabeth@email.com', '9999999999', '258 Walnut St, City2', '2024-02-28'),
('David Anderson', 'david@email.com', '8888888888', '369 Spruce Rd, City3', '2024-01-10'),
('Jennifer Martin', 'jennifer@email.com', '7777777777', '741 Pine St, City1', '2024-03-10');


INSERT INTO BorrowingRecords (MEMBER_ID, BOOK_ID, BORROW_DATE, RETURN_DATE) VALUES
(1, 1, '2024-03-01', '2024-03-15'),
(2, 2, '2024-03-10', NULL),
(3, 3, '2024-02-15', '2024-03-01'),
(4, 4, '2024-03-05', NULL),
(5, 5, '2024-02-20', '2024-03-06'),
(6, 6, '2024-03-12', NULL),
(7, 7, '2024-02-25', '2024-03-11'),
(8, 8, '2024-03-08', NULL),
(9, 9, '2024-02-28', '2024-03-14'),
(10, 10, '2024-03-15', NULL);
-- a) Retrieve books currently borrowed by a specific member
SELECT m.NAME as Member_Name,
    b.TITLE as Book_Title,
    br.BORROW_DATE,
    DATEDIFF(CURDATE(), br.BORROW_DATE) as Days_Borrowed
FROM BorrowingRecords br JOIN Books b ON br.BOOK_ID = b.BOOK_ID 
JOIN Members m ON br.MEMBER_ID = m.MEMBER_ID
WHERE m.MEMBER_ID = 1;

-- b) Find members with overdue books (borrowed more than 30 days ago, not returned)
SELECT 
    m.NAME,
    m.EMAIL,
    m.PHONE_NO,
    b.TITLE as Book_Title,
    br.BORROW_DATE,
    DATEDIFF(CURDATE(), br.BORROW_DATE) as Days_Overdue
FROM BorrowingRecords br
JOIN Members m ON br.MEMBER_ID = m.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
WHERE br.RETURN_DATE IS NULL 
AND DATEDIFF(CURDATE(), br.BORROW_DATE) > 30
ORDER BY Days_Overdue DESC;

-- c) Retrieve books by genre with available copies count
SELECT 
    GENRE,
    COUNT(*) as Total_Books,
    SUM(AVAILABLE_COPIES) as Total_Available_Copies,
    GROUP_CONCAT(TITLE) as Books_in_Genre
FROM Books
GROUP BY GENRE
ORDER BY GENRE;
-- d) Find the most borrowed book(s) overall
SELECT 
    b.TITLE,
    b.AUTHOR,
    COUNT(br.BOOK_ID) as Times_Borrowed
FROM Books b
LEFT JOIN BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
GROUP BY b.BOOK_ID, b.TITLE, b.AUTHOR
HAVING Times_Borrowed = (
    SELECT COUNT(BOOK_ID) as borrow_count
    FROM BorrowingRecords
    GROUP BY BOOK_ID
    ORDER BY borrow_count DESC
    LIMIT 1
)
ORDER BY Times_Borrowed DESC;


-- e) Retrieve members who have borrowed books from at least three different genres
SELECT 
    m.MEMBER_ID,
    m.NAME,
    COUNT(DISTINCT b.GENRE) as Different_Genres_Borrowed,
    GROUP_CONCAT(DISTINCT b.GENRE) as Genres_Borrowed
FROM Members m
JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
GROUP BY m.MEMBER_ID, m.NAME
HAVING COUNT(DISTINCT b.GENRE) >= 3
ORDER BY Different_Genres_Borrowed DESC;


-- Library Management System - Reporting and Analytics Queries

-- Q: How many books were borrowed each month?
SELECT 
    DATE_FORMAT(BORROW_DATE, '%Y-%m') as Month,
    COUNT(*) as Total_Borrowings,
    COUNT(DISTINCT MEMBER_ID) as Unique_Borrowers,
    COUNT(DISTINCT BOOK_ID) as Unique_Books_Borrowed
FROM BorrowingRecords
GROUP BY DATE_FORMAT(BORROW_DATE, '%Y-%m')
ORDER BY Month DESC;

-- Q: Who are the top 3 most active members based on number of books borrowed?
SELECT 
    m.NAME,
    COUNT(br.BORROW_ID) as Books_Borrowed,
    COUNT(DISTINCT b.GENRE) as Different_Genres_Borrowed,
    MAX(br.BORROW_DATE) as Last_Borrow_Date
FROM Members m
JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
GROUP BY m.MEMBER_ID, m.NAME
ORDER BY Books_Borrowed DESC
LIMIT 3;

-- Q: Which authors' books have been borrowed at least 10 times?
SELECT 
    b.AUTHOR,
    COUNT(br.BORROW_ID) as Times_Borrowed,
    COUNT(DISTINCT b.BOOK_ID) as Different_Books_Borrowed,
    GROUP_CONCAT(DISTINCT b.TITLE) as Books_List
FROM Books b
JOIN BorrowingRecords br ON b.BOOK_ID = br.BOOK_ID
GROUP BY b.AUTHOR
HAVING COUNT(br.BORROW_ID) >= 10
ORDER BY Times_Borrowed DESC;

-- Q: Which members have never borrowed a book?
SELECT 
    m.MEMBER_ID,
    m.NAME,
    m.EMAIL,
    m.MEMBERSHIP_DATE,
    DATEDIFF(CURDATE(), m.MEMBERSHIP_DATE) as Days_Since_Joining
FROM Members m
LEFT JOIN BorrowingRecords br ON m.MEMBER_ID = br.MEMBER_ID
WHERE br.BORROW_ID IS NULL;



