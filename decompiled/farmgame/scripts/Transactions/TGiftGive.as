package Transactions
{
   public class TGiftGive extends TFarmTransaction
   {
      
      protected var m_action:String;
      
      protected var m_bundleData:Object;
      
      protected var m_strTargetIds:Array;
      
      public function TGiftGive(action:String, bundleData:Object, targetIds:Array)
      {
         var idX:int = 0;
         this.m_strTargetIds = new Array();
         super();
         this.m_action = action;
         this.m_bundleData = bundleData;
         if(targetIds)
         {
            for(idX = 0; idX < targetIds.length; idX++)
            {
               this.m_strTargetIds.push(targetIds[idX].toString());
            }
         }
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.sendEmailFeed",this.m_action,this.m_bundleData);
      }
   }
}

