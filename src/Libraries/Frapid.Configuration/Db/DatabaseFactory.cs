using Frapid.Mapper.Database;

namespace Frapid.Configuration.Db
{
    public sealed class DatabaseFactory
    {
        public DatabaseFactory(MapperDb db)
        {
            this.Db = db;
        }

        private MapperDb Db { get; }

        public MapperDb GetDatabase()
        {
            return this.Db;
        }
    }
}