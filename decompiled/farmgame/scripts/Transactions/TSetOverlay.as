package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TSetOverlay extends TWorldState
   {
      
      protected var m_overlay:String = "";
      
      public function TSetOverlay(object:WorldObject, overlayName:String = "")
      {
         super(object);
         this.m_overlay = overlayName;
      }
      
      override public function perform() : void
      {
         signedWorldAction("SetOverlay",{"overlayName":this.m_overlay});
      }
   }
}

