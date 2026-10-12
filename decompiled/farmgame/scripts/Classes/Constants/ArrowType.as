package Classes.Constants
{
   import Display.DynamicIconQueue;
   
   public class ArrowType
   {
      
      public static const ARROWNEW:ArrowType = new ArrowType("bouncing_new_arrow");
      
      public static const ARROWUPDATE:ArrowType = new ArrowType("bouncing_progress_arrow");
      
      public static const ARROWEXPIRY:ArrowType = new ArrowType("bouncing_expiry_arrow");
      
      public static const BONUSPARTS:ArrowType = new ArrowType("bouncing_bonus_parts_arrow");
      
      private var m_embeddedArtName:String;
      
      public function ArrowType(embeddedArtName:String)
      {
         super();
         this.m_embeddedArtName = embeddedArtName;
      }
      
      public function getEmbeddedArtName(side:int) : String
      {
         var artName:String = this.m_embeddedArtName;
         if(side == DynamicIconQueue.RIGHT_SIDE)
         {
            artName += "_right";
         }
         return artName;
      }
   }
}

