// Sesuaikan lagi field-nya kalau ternyata beda dengan response asli dari
// https://library-backend-production-b9cf.up.railway.app/api-swagger
// (aku nggak bisa fetch JSON spec-nya dari sini, jadi ini "best guess"
// berdasarkan tampilan Figma + MVP guide)

export interface Book {
  id: string;
  title: string;
  author: string;
  category: string;
  coverUrl: string;
  rating: number;
  stock: number;
  reviewCount: number;
  description: string;
}

export interface Review {
  id: string;
  userName: string;
  userAvatarUrl: string;
  rating: number; // 1-5
  comment: string;
  createdAt: string; // ISO date string
}

export interface RelatedBook {
  id: string;
  title: string;
  author: string;
  coverUrl: string;
  rating: number;
}
