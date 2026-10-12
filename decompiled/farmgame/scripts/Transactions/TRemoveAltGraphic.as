package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TRemoveAltGraphic extends TWorldState
   {
      
      protected var m_name:String = "";
      
      public function TRemoveAltGraphic(object:WorldObject, name:String = "")
      {
         this.m_name = name;
         super(object);
      }
      
      override public function perform() : void
      {
         signedWorldAction("RemoveAltGraphic",{"name":this.m_name});
      }
   }
}

