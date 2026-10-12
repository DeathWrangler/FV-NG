package Classes.Zoom
{
   public class ZoomMessage
   {
      
      protected var m_type:String;
      
      protected var m_sender:String;
      
      protected var m_content:String;
      
      protected var m_timeStamp:Number;
      
      public function ZoomMessage(type:String, sender:String, content:String, timeStamp:Number = -1)
      {
         super();
         this.m_type = type;
         this.m_sender = sender;
         this.m_content = content;
         this.m_timeStamp = timeStamp;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get sender() : String
      {
         return this.m_sender;
      }
      
      public function get content() : String
      {
         return this.m_content;
      }
      
      public function get timeStamp() : Number
      {
         return this.m_timeStamp;
      }
   }
}

