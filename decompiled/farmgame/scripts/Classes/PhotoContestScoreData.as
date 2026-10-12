package Classes
{
   public class PhotoContestScoreData
   {
      
      private var m_data:Object = null;
      
      private var m_score:int = 0;
      
      private var m_url:String = null;
      
      private var m_key:String = null;
      
      private var m_isOffensive:Boolean = false;
      
      public function PhotoContestScoreData()
      {
         super();
      }
      
      public function set score(value:int) : void
      {
         this.m_score = value;
      }
      
      public function get score() : int
      {
         return this.m_score;
      }
      
      public function set key(value:String) : void
      {
         this.m_key = value;
      }
      
      public function get key() : String
      {
         return this.m_key;
      }
      
      public function get imageUrl() : String
      {
         return this.m_url;
      }
      
      public function get isAbusive() : Boolean
      {
         return this.m_isOffensive;
      }
      
      public function set isAbusive(value:Boolean) : void
      {
         this.m_isOffensive = value;
      }
      
      public function set imageUrl(url:String) : void
      {
         this.m_url = url;
      }
   }
}

