package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TSetFestivalOfColorGraphic extends TWorldState
   {
      
      protected var m_graphic:String = "";
      
      public function TSetFestivalOfColorGraphic(object:WorldObject, graphicName:String)
      {
         super(object);
         this.m_graphic = graphicName;
      }
      
      override public function perform() : void
      {
         signedWorldAction("SetFestivalOfColorGraphic",{"graphicName":this.m_graphic});
      }
   }
}

