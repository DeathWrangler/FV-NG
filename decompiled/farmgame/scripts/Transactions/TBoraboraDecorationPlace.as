package Transactions
{
   import Classes.Decoration;
   import Engine.Managers.SoundManager;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   
   public class TBoraboraDecorationPlace extends TPlace
   {
      
      private var m_decoration:Decoration;
      
      public function TBoraboraDecorationPlace(decoration:Decoration, isGift:Boolean = false, containerId:int = 0, currency:String = "")
      {
         SoundManager.playSound("decorate");
         super(decoration);
         if(m_item)
         {
            BoraBoraInnovationManager.getInstance().updateItemCountMapping(m_item.code);
         }
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
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_PLACE;
         result.item = m_item;
         result.params = m_params;
         result.isStorageWithdrawl = m_params.isStorageWithdrawal;
         return result;
      }
      
      override protected function signedWorldAction(actionName:String, ... params) : void
      {
         if(true == m_isFirstWorldAction && actionName != "move")
         {
            m_isFirstWorldAction = false;
            params.push({"firstWA":true});
         }
         signedCall("BoraboraWorldService." + METHOD_PERFORM_ACTION,actionName,m_save,params);
         m_functionName = "BoraboraWorldService." + METHOD_PERFORM_ACTION + ":" + actionName;
      }
   }
}

