package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TSetAltGraphic extends TWorldState
   {
      
      protected var m_graphic:String = "";
      
      public function TSetAltGraphic(object:WorldObject, graphicName:String = "")
      {
         super(object);
         this.m_graphic = graphicName;
      }
      
      override public function perform() : void
      {
         signedWorldAction("SetAltGraphic",{"graphicName":this.m_graphic});
      }
   }
}

