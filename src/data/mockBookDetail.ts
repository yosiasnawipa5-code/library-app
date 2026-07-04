import { Book, Review, RelatedBook } from "../types/book";

export const mockBook: Book = {
  id: "1",
  title: "The Psychology of Money",
  author: "Morgan Housel",
  category: "Business & Economics",
  coverUrl: "https://picsum.photos/seed/psychology-of-money/450/600",
  rating: 4.9,
  stock: 320,
  reviewCount: 179,
  description:
    'The Psychology of Money" explores how emotions, biases, and human behavior shape the way we think about money, investing, and financial decisions. Morgan Housel shares timeless lessons on wealth, greed, and happiness, showing that financial success is not about knowledge, but about behavior.',
};

export const mockReviews: Review[] = Array.from({ length: 6 }).map((_, i) => ({
  id: String(i + 1),
  userName: "John Doe",
  userAvatarUrl: "/images/avatar-placeholder.jpg",
  rating: 5,
  comment:
    "Lorem ipsum dolor sit amet consectetur. Pulvinar porttitor aliquam viverra nunc sed facilisis. Integer tristique nullam morbi mauris ante.",
  createdAt: "2025-08-25T13:38:00Z",
}));

export const mockRelatedBooks: RelatedBook[] = [
  { id: "2", title: "21 Rasa Bakso Pak Bowo", author: "Author name", coverUrl: "https://picsum.photos/seed/related-1/300/400", rating: 4.9 },
  { id: "3", title: "Irresistible", author: "Lisa Kleypas", coverUrl: "https://picsum.photos/seed/related-2/300/400", rating: 4.9 },
  { id: "4", title: "Oliver Twist", author: "Charles Dickens", coverUrl: "https://picsum.photos/seed/related-3/300/400", rating: 4.9 },
  { id: "5", title: "White Fang", author: "Jack London", coverUrl: "https://picsum.photos/seed/related-4/300/400", rating: 4.9 },
  { id: "6", title: "The Scarred Woman", author: "Jussi Adler-Olsen", coverUrl: "https://picsum.photos/seed/related-5/300/400", rating: 4.9 },
];
