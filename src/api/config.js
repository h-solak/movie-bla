import axios from "axios";

//Our API config
const misBaseAxios = axios.create({
  // Set VITE_API_URL in .env.local (e.g. http://localhost:5900/api) to use a local backend
  baseURL:
    import.meta.env.VITE_API_URL ||
    "https://mis492-final-project.onrender.com/api",
  //
  headers: {
    "Content-Type": "application/json",
  },
});

const setAccessToken = (token) => {
  if (token) {
    localStorage.setItem("mis492_jwt", token);
    misBaseAxios.defaults.headers.common["Authorization"] = token;
  } else {
    removeAccessToken();
  }
};

const removeAccessToken = () => {
  localStorage.removeItem("mis492_jwt");
  delete misBaseAxios.defaults.headers.common["Authorization"];
};

const accessToken = localStorage.getItem("mis492_jwt");
if (accessToken) {
  setAccessToken(accessToken);
}

//TMDB API config
const tmdbBaseAxios = axios.create({
  baseURL: "https://api.themoviedb.org/3/",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4NWM3YWExZWY4N2RkNWFmMzU5YzdjMTU3NTBmMGQ5ZSIsInN1YiI6IjYzMzg5YmJiNTAxY2YyMDA3OTVlOGI2ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.kVvFk76QJsJlVv2gWtwp3fGEZzCsGUNpG7r1UB00H1E`,
  },
});

export { misBaseAxios, setAccessToken, removeAccessToken, tmdbBaseAxios };
