package Transactions
{
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Widgets.Windows.TwentiesInnovationTileUnlockwindow;
   
   public class TTransformTreasure extends TWorldState
   {
      
      public static const ACTION_TRANSFORM_BUILDING:String = "TransformBuilding";
      
      public static const ACTION_TRANSFORM_BUILDING_CASHLESS:String = "UnlockNow";
      
      protected var m_building:MultiRewardTreasureConstructionBuilding;
      
      protected var m_transformOnComplete:Boolean;
      
      protected var m_successCallback:Function;
      
      protected var m_shouldUnlockNow:Boolean;
      
      public function TTransformTreasure(building:MultiRewardTreasureConstructionBuilding, transformOnComplete:Boolean = false, callback:Function = null, shouldUnlockNow:Boolean = false)
      {
         this.m_building = building;
         this.m_transformOnComplete = transformOnComplete;
         this.m_successCallback = callback;
         this.m_shouldUnlockNow = shouldUnlockNow;
         super(building);
      }
      
      override public function perform() : void
      {
         if(this.m_shouldUnlockNow)
         {
            signedWorldAction(ACTION_TRANSFORM_BUILDING_CASHLESS);
         }
         else
         {
            signedWorldAction(ACTION_TRANSFORM_BUILDING);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         if(this.m_shouldUnlockNow)
         {
            result.action = ACTION_TRANSFORM_BUILDING_CASHLESS;
         }
         else
         {
            result.action = ACTION_TRANSFORM_BUILDING;
         }
         result.item = this.m_building.getItem();
         result.building = this.m_building;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var fenceCode:String = null;
         var ConsumableItem:FarmItem = null;
         if(result != null && result.finishedItems.length > 0 && result.finishedItems[1].name.indexOf("xrt") >= 0)
         {
            fenceCode = "26xg";
            ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(fenceCode);
            UI.displayPopup(new TwentiesInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf","TwentiesInnovation",ConsumableItem,null,"assets/dialogs/twenties/RewardDialog.png"));
         }
         super.onComplete(result);
         if(Boolean(result) && Boolean(this.m_building))
         {
            if(this.m_transformOnComplete)
            {
               this.m_building.transformBuilding(result);
            }
            this.m_building.onFullyFinished(result);
            if(this.m_successCallback !== null)
            {
               this.m_successCallback.call(null,result);
            }
         }
      }
   }
}

