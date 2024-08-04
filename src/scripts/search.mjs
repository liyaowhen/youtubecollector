import yts from 'yt-search';
import process from 'node:process';

const query = process.argv.slice(2).join(' ');

async function searchYouTube(query) {
    try {
        if (!query) {
            console.error('Please provide a search query.');
            process.exit(1);
        }

        const results = (await yts(query)).videos.slice(0,5);
        console.log(JSON.stringify(results, null, 2)); // Pretty-print JSON with 2-space indentation
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

searchYouTube(query);