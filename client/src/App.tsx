import React, { useEffect, useState } from 'react';
import logo from './logo.svg';
import './App.css';

interface Book { title: string, author: string };

function App() {
  const [books, setBooks] = useState<Book[]>([]);
  const [emailAddress, setEmailAddress] = useState<string>('');

  const subscribe = async () => {
    await fetch(
      'http://localhost:8080/subscriptions',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email: emailAddress })
      }
    ).then(() => {
      setEmailAddress('')
    })
  }
  
  useEffect(() => {
    const fetchData = async () => {
      const books = await fetch(
        'http://localhost:8080/books'
      ).then(r => {
        return r.json()
      });

      setBooks(books);
    };
  
    fetchData();
  }, []);

  console.log(books);
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
        <h2>Here are the books I've read lately</h2>
        <ul>
          {books.map(({ title, author }: Book, i: number) => (<li key={title+i}>{title} by {author}</li>))}
        </ul>
        <input type='text' value={emailAddress} onChange={e => setEmailAddress(e.target.value)}></input>
        <button onClick={subscribe}>subscribe</button>
      </header>
    </div>
  );
}

export default App;
