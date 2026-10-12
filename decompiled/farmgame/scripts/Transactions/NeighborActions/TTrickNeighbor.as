package Transactions.NeighborActions
{
   import Classes.ZItem.FarmItem;
   import Engine.Classes.WorldObject;
   import Managers.ToasterManager;
   import Managers.TrickOrTreatManager;
   import Widgets.Windows.TrickOrTreatToasterWindow;
   
   public class TTrickNeighbor extends TBaseNeighborAction
   {
      
      public function TTrickNeighbor(object:WorldObject)
      {
         m_actionType = "trickneighbor";
         super(object);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItem:FarmItem = null;
         super.onComplete(result);
         if(TrickOrTreatManager.instance.hasSeenToaster == false && result.reward_link != null && result.gift != null)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(result.gift);
            if(giftItem)
            {
               ToasterManager.getInstance().add(new TrickOrTreatToasterWindow(result.shareFeedId,giftItem,result.reward_link));
               TrickOrTreatManager.instance.hasSeenToaster = true;
            }
         }
      }
   }
}

