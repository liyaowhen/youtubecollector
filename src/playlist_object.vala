namespace Song {

    public class PlaylistObject : Object {

        public string name;
        public List<PlaylistItem> items; //videos or songs

        public void add_item(PlaylistItem item) {
            items.append(item);
        }
    }

    public class PlaylistItem : Object {
        public ItemType item_type;
        public string name;
        public string? source = null; // null when the source is local
        public string file;
        public string? picture = null; // null when the item has no picture

        public static PlaylistItem load_item(ItemType item_type, string file, string picture) {
            PlaylistItem item = new PlaylistItem();
            item.item_type = item_type;
            item.file = file;
            item.picture = picture;

            return item;
        }
    }
}