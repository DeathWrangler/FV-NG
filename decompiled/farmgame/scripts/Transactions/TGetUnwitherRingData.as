package Transactions
{
   import Classes.Decoration;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Display.UnwitherRingDetails;
   
   public class TGetUnwitherRingData extends TFarmTransaction
   {
      
      protected var m_ringID:Number;
      
      protected var m_farmItem:FarmItem;
      
      public function TGetUnwitherRingData(ring:Decoration, farmItem:FarmItem)
      {
         this.m_ringID = ring.getId();
         this.m_farmItem = farmItem;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getUnwitherRingData",this.m_ringID);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.success)
         {
            if(result.extraItemData)
            {
               if(result.extraItemData.sender != -1)
               {
                  UI.displayPopup(new UnwitherRingDetails(result.extraItemData.sender,result.extraItemData.ringType,result.extraItemData.message));
               }
               else
               {
                  UI.displayPopup(new UnwitherRingDetails(Global.player.uid,this.m_farmItem.code,result.extraItemData.message));
               }
            }
         }
      }
   }
}

