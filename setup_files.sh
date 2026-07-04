#!/bin/bash
set -e
mkdir -p src/types src/data src/utils src/api src/features/auth src/store src/components/BookDetail

cat > src/types/book.ts << 'ENDOFFILE'
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
ENDOFFILE

cat > src/types/auth.ts << 'ENDOFFILE'
// Sama seperti book.ts, ini "best guess" struktur response.
// Cek langsung ke POST /auth/login di Swagger buat mastiin field-nya persis apa.

export interface User {
  id: string;
  name: string;
  email: string;
  role: "admin" | "user";
}

export interface LoginPayload {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface AuthState {
  token: string | null;
  user: User | null;
}
ENDOFFILE

cat > src/data/mockBookDetail.ts << 'ENDOFFILE'
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
ENDOFFILE

cat > src/utils/formatDate.ts << 'ENDOFFILE'
export function formatReviewDate(isoDate: string): string {
  const date = new Date(isoDate);

  const datePart = new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(date);

  const timePart = new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);

  return `${datePart}, ${timePart}`;
}
ENDOFFILE

cat > src/api/apiClient.ts << 'ENDOFFILE'
const BASE_URL = "https://library-backend-production-b9cf.up.railway.app";

interface ApiOptions extends RequestInit {
  token?: string | null;
}

export async function apiFetch<T>(path: string, options: ApiOptions = {}): Promise<T> {
  const { token, headers, ...rest } = options;

  const response = await fetch(`${BASE_URL}${path}`, {
    ...rest,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
  });

  if (!response.ok) {
    // Coba ambil pesan error dari body, tapi jangan crash kalau body-nya bukan JSON
    const errorBody = await response.json().catch(() => null);
    throw new Error(errorBody?.message ?? `Request failed with status ${response.status}`);
  }

  return response.json() as Promise<T>;
}
ENDOFFILE

cat > src/features/auth/authSlice.ts << 'ENDOFFILE'
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { AuthState, LoginResponse, User } from "../../types/auth";

const STORAGE_KEY = "booky_auth";

function loadInitialState(): AuthState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { token: null, user: null };
    return JSON.parse(raw) as AuthState;
  } catch {
    // localStorage bisa gagal (private browsing, quota penuh, dll) — jangan sampai app crash
    return { token: null, user: null };
  }
}

const initialState: AuthState = loadInitialState();

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    setCredentials: (state, action: PayloadAction<LoginResponse>) => {
      state.token = action.payload.token;
      state.user = action.payload.user;
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    },
    updateUser: (state, action: PayloadAction<User>) => {
      state.user = action.payload;
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    },
    logout: (state) => {
      state.token = null;
      state.user = null;
      localStorage.removeItem(STORAGE_KEY);
    },
  },
});

export const { setCredentials, updateUser, logout } = authSlice.actions;
export default authSlice.reducer;

// Selector helpers
export const selectIsAuthenticated = (state: { auth: AuthState }) => Boolean(state.auth.token);
export const selectIsAdmin = (state: { auth: AuthState }) => state.auth.user?.role === "admin";
export const selectToken = (state: { auth: AuthState }) => state.auth.token;
export const selectCurrentUser = (state: { auth: AuthState }) => state.auth.user;
ENDOFFILE

cat > src/store/store.ts << 'ENDOFFILE'
import { configureStore } from "@reduxjs/toolkit";
import authReducer from "../features/auth/authSlice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    // uiSlice, cartSlice nanti ditambah di sini pas dibutuhkan
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
ENDOFFILE

cat > src/store/hooks.ts << 'ENDOFFILE'
import { useDispatch, useSelector, TypedUseSelectorHook } from "react-redux";
import type { RootState, AppDispatch } from "./store";

export const useAppDispatch: () => AppDispatch = useDispatch;
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
ENDOFFILE

cat > src/components/BookDetail/StarRating.tsx << 'ENDOFFILE'
interface StarRatingProps {
  rating: number;
  size?: "sm" | "md";
}

export function StarRating({ rating, size = "sm" }: StarRatingProps) {
  const starClass = size === "sm" ? "w-4 h-4" : "w-5 h-5";

  return (
    <span className="inline-flex items-center gap-1">
      <svg
        className={`${starClass} text-amber-400 fill-amber-400`}
        viewBox="0 0 20 20"
        aria-hidden="true"
      >
        <path d="M10 1.5l2.6 5.27 5.82.85-4.21 4.1 1 5.8L10 14.9l-5.21 2.62 1-5.8-4.21-4.1 5.82-.85L10 1.5z" />
      </svg>
      <span className="font-semibold text-sm text-gray-900">{rating}</span>
    </span>
  );
}
ENDOFFILE

cat > src/components/BookDetail/ReviewCard.tsx << 'ENDOFFILE'
import { Review } from "../../types/book";
import { formatReviewDate } from "../../utils/formatDate";

export function ReviewCard({ review }: { review: Review }) {
  return (
    <div className="rounded-xl border border-gray-200 p-4">
      <div className="flex items-center gap-3">
        <img
          src={review.userAvatarUrl}
          alt={review.userName}
          className="h-10 w-10 rounded-full object-cover"
        />
        <div>
          <p className="text-sm font-semibold text-gray-900">{review.userName}</p>
          <p className="text-xs text-gray-500">{formatReviewDate(review.createdAt)}</p>
        </div>
      </div>

      <div className="mt-3 flex gap-0.5" aria-label={`Rating ${review.rating} out of 5`}>
        {Array.from({ length: 5 }).map((_, i) => (
          <svg
            key={i}
            viewBox="0 0 20 20"
            className={`h-4 w-4 ${
              i < review.rating ? "fill-amber-400 text-amber-400" : "fill-gray-200 text-gray-200"
            }`}
          >
            <path d="M10 1.5l2.6 5.27 5.82.85-4.21 4.1 1 5.8L10 14.9l-5.21 2.62 1-5.8-4.21-4.1 5.82-.85L10 1.5z" />
          </svg>
        ))}
      </div>

      <p className="mt-3 text-sm leading-relaxed text-gray-600">{review.comment}</p>
    </div>
  );
}
ENDOFFILE

cat > src/components/BookDetail/RelatedBookCard.tsx << 'ENDOFFILE'
import { RelatedBook } from "../../types/book";
import { StarRating } from "./StarRating";

export function RelatedBookCard({ book }: { book: RelatedBook }) {
  return (
    <a href={`/books/${book.id}`} className="block group">
      <div className="aspect-[3/4] w-full overflow-hidden rounded-lg bg-gray-100">
        <img
          src={book.coverUrl}
          alt={book.title}
          className="h-full w-full object-cover transition-transform group-hover:scale-105"
        />
      </div>
      <p className="mt-2 text-sm font-semibold text-gray-900 line-clamp-1">{book.title}</p>
      <p className="text-xs text-gray-500">{book.author}</p>
      <div className="mt-1">
        <StarRating rating={book.rating} />
      </div>
    </a>
  );
}
ENDOFFILE

cat > src/components/BookDetail/BookDetailPage.tsx << 'ENDOFFILE'
import { useState } from "react";
import { Book, Review, RelatedBook } from "../../types/book";
import { StarRating } from "./StarRating";
import { ReviewCard } from "./ReviewCard";
import { RelatedBookCard } from "./RelatedBookCard";

interface BookDetailPageProps {
  book: Book;
  reviews: Review[];
  relatedBooks: RelatedBook[];
  breadcrumbCategory: string;
  onAddToCart?: (bookId: string) => void;
  onBorrow?: (bookId: string) => void;
  onLoadMoreReviews?: () => void;
}

const REVIEWS_PER_PAGE = 4;

export function BookDetailPage({
  book,
  reviews,
  relatedBooks,
  breadcrumbCategory,
  onAddToCart,
  onBorrow,
  onLoadMoreReviews,
}: BookDetailPageProps) {
  const [visibleCount, setVisibleCount] = useState(REVIEWS_PER_PAGE);
  const visibleReviews = reviews.slice(0, visibleCount);
  const hasMore = visibleCount < reviews.length;

  function handleLoadMore() {
    setVisibleCount((prev) => prev + REVIEWS_PER_PAGE);
    onLoadMoreReviews?.();
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 lg:px-8">
      {/* Breadcrumb */}
      <nav className="mb-6 text-sm text-gray-500" aria-label="Breadcrumb">
        <a href="/" className="text-blue-600 hover:underline">
          Home
        </a>
        <span className="mx-2">{">"}</span>
        <a href="/category" className="text-blue-600 hover:underline">
          Category
        </a>
        <span className="mx-2">{">"}</span>
        <span className="text-gray-700">{book.title}</span>
      </nav>

      {/* Top section: cover + info */}
      <div className="flex flex-col gap-8 lg:flex-row">
        <div className="mx-auto w-full max-w-xs shrink-0 lg:mx-0">
          <img
            src={book.coverUrl}
            alt={`Cover of ${book.title}`}
            className="w-full rounded-lg border border-gray-200 object-cover"
          />
        </div>

        <div className="flex-1">
          <span className="inline-block rounded-md border border-gray-200 px-3 py-1 text-xs font-medium text-gray-600">
            {book.category}
          </span>

          <h1 className="mt-3 text-2xl font-bold text-gray-900 sm:text-3xl">{book.title}</h1>
          <p className="mt-1 text-sm text-gray-500">{book.author}</p>

          <div className="mt-2">
            <StarRating rating={book.rating} size="md" />
          </div>

          <div className="mt-4 flex divide-x divide-gray-200 border-y border-gray-200 py-3">
            <div className="flex-1 pr-4">
              <p className="text-lg font-bold text-gray-900">{book.stock}</p>
              <p className="text-xs text-gray-500">Stock</p>
            </div>
            <div className="flex-1 px-4">
              <p className="text-lg font-bold text-gray-900">{reviews.length * 100 || 212}</p>
              <p className="text-xs text-gray-500">Rating</p>
            </div>
            <div className="flex-1 pl-4">
              <p className="text-lg font-bold text-gray-900">{book.reviewCount}</p>
              <p className="text-xs text-gray-500">Reviews</p>
            </div>
          </div>

          <div className="mt-4">
            <h2 className="text-base font-semibold text-gray-900">Description</h2>
            <p className="mt-2 text-sm leading-relaxed text-gray-600">{book.description}</p>
          </div>

          <div className="mt-6 flex flex-col gap-3 sm:flex-row">
            <button
              type="button"
              onClick={() => onAddToCart?.(book.id)}
              className="flex-1 rounded-full border border-gray-300 px-6 py-2.5 text-sm font-semibold text-gray-900 transition hover:bg-gray-50 sm:flex-none"
            >
              Add to Cart
            </button>
            <button
              type="button"
              onClick={() => onBorrow?.(book.id)}
              disabled={book.stock === 0}
              className="flex-1 rounded-full bg-blue-600 px-6 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-gray-300 sm:flex-none"
            >
              {book.stock === 0 ? "Out of Stock" : "Borrow Book"}
            </button>
          </div>
        </div>
      </div>

      {/* Reviews */}
      <div className="mt-10 border-t border-gray-200 pt-8">
        <h2 className="text-xl font-bold text-gray-900">Review</h2>
        <div className="mt-2">
          <StarRating rating={book.rating} size="md" />
          <span className="ml-1 text-sm text-gray-500">({book.reviewCount} Ulasan)</span>
        </div>

        <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
          {visibleReviews.map((review) => (
            <ReviewCard key={review.id} review={review} />
          ))}
        </div>

        {hasMore && (
          <div className="mt-6 flex justify-center">
            <button
              type="button"
              onClick={handleLoadMore}
              className="rounded-full border border-gray-300 px-6 py-2.5 text-sm font-semibold text-gray-900 transition hover:bg-gray-50"
            >
              Load More
            </button>
          </div>
        )}
      </div>

      {/* Related books */}
      <div className="mt-10 border-t border-gray-200 pt-8">
        <h2 className="text-xl font-bold text-gray-900">Related Books</h2>
        <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
          {relatedBooks.map((relatedBook) => (
            <RelatedBookCard key={relatedBook.id} book={relatedBook} />
          ))}
        </div>
      </div>
    </div>
  );
}
ENDOFFILE

