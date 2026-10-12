package Classes.feed
{
   public class FarmFeed
   {
      
      protected var m_bundleId:String = "";
      
      protected var m_params:Object = new Object();
      
      protected var m_targetUids:Array = new Array();
      
      protected var m_publishCallback:Function = null;
      
      public function FarmFeed()
      {
         super();
      }
      
      public function publish() : void
      {
         GlobalEngine.socialNetwork.publishFeedStory(this.m_bundleId,this.m_params,this.m_targetUids,false,this.m_publishCallback);
      }
   }
}

