package Transactions
{
   import flash.utils.getQualifiedClassName;
   
   public class TCompleteFertilize extends TFarmTransaction
   {
      
      protected var m_userId:String;
      
      protected var m_fertilizerHostId:String;
      
      public function TCompleteFertilize()
      {
         super();
         this.m_userId = Global.player.snUser.uid;
         this.m_fertilizerHostId = Global.worldManager.getVisiting();
      }
      
      override public function perform() : void
      {
         signedCall("FertilizerService.completeFertilize",this.m_fertilizerHostId.toString());
      }
      
      override protected function onComplete(result:Object) : void
      {
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         GlobalEngine.log("FertilizerComplete","Fault in " + getQualifiedClassName(this) + ": " + errorData);
      }
   }
}

