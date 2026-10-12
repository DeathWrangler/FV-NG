package Classes.util
{
   public class ZLocFailoverEntry
   {
      
      private var m_pkg:String = null;
      
      private var m_key:String = null;
      
      public function ZLocFailoverEntry(pkg:String, key:String = null)
      {
         super();
         var pkgkey:Array = [pkg,key];
         ZLocUtils.splitPkgKey(pkgkey);
         this.m_pkg = pkgkey[0];
         this.m_key = pkgkey[1];
      }
      
      public function get pkg() : String
      {
         return this.m_pkg;
      }
      
      public function get key() : String
      {
         return this.m_key;
      }
   }
}

