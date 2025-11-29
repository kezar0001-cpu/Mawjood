export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  public: {
    Tables: {
      admins: {
        Row: {
          id: string;
          user_id: string;
          email: string;
          role: string;
          created_at: string | null;
        };
        Insert: {
          id?: string;
          user_id: string;
          email: string;
          role?: string;
          created_at?: string | null;
        };
        Update: {
          id?: string;
          user_id?: string;
          email?: string;
          role?: string;
          created_at?: string | null;
        };
      };
      businesses: {
        Row: {
          id: string;
          name: string;
          category_id: string | null;
          description: string | null;
          city: string | null;
          address: string | null;
          phone: string | null;
          rating: number | null;
          latitude: number | null;
          longitude: number | null;
          images: string[] | null;
          features: string[] | null;
        };
        Insert: {
          id?: string;
          name: string;
          category_id?: string | null;
          description?: string | null;
          city?: string | null;
          address?: string | null;
          phone?: string | null;
          rating?: number | null;
          latitude?: number | null;
          longitude?: number | null;
          images?: string[] | null;
          features?: string[] | null;
        };
        Update: {
          id?: string;
          name?: string;
          category_id?: string | null;
          description?: string | null;
          city?: string | null;
          address?: string | null;
          phone?: string | null;
          rating?: number | null;
          latitude?: number | null;
          longitude?: number | null;
          images?: string[] | null;
          features?: string[] | null;
        };
      };
      categories: {
        Row: {
          id: string;
          name_ar: string;
          name_en: string | null;
          icon: string | null;
        };
        Insert: {
          id?: string;
          name_ar: string;
          name_en?: string | null;
          icon?: string | null;
        };
        Update: {
          id?: string;
          name_ar?: string;
          name_en?: string | null;
          icon?: string | null;
        };
      };
    };
  };
};
