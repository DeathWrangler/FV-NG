package Transactions
{
   import Classes.Decoration;
   import Engine.Managers.SoundManager;
   
   public class TDecorationPlace extends TPlace
   {
      
      private var m_decoration:Decoration;
      
      public function TDecorationPlace(decoration:Decoration, isGift:Boolean = false, containerId:int = 0, currency:String = "")
      {
         SoundManager.playSound("decorate");
         super(decoration);
         m_params.isGift = isGift;
         m_params.isStorageWithdrawal = containerId;
         m_params.isInventoryWithdrawal = containerId == Global.worldManager.getCurrentWorldStorageId();
         m_params.currency = currency;
         if(m_params.isGift == true)
         {
            Global.player.removeGift(decoration);
         }
         this.m_decoration = decoration;
         this.m_decoration.isNew = true;
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_decoration != null)
         {
            this.m_decoration.onPlacedFirstTime();
            this.m_decoration.onFinishPlace(result);
         }
         this.m_decoration.isNew = false;
         super.onComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = super.getTransactionData();
         result.isStorageWithdrawl = m_params.isStorageWithdrawal;
         return result;
      }
   }
}

