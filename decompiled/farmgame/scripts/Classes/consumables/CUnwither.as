package Classes.consumables
{
   import Classes.Consumable;
   import Classes.Plot;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   
   public class CUnwither extends Consumable
   {
      
      public static const UNWITHER_ITEMCODE:String = "A3";
      
      protected var m_plots:Array = Global.world.getObjectsByClass(Plot);
      
      private var m_targetedUserId:String = "";
      
      public function CUnwither(itemName:String)
      {
         super(itemName);
      }
      
      override public function onUse() : void
      {
         var plot:Plot = null;
         var plotIdx:int = 0;
         if(this.canUse())
         {
            for(plotIdx = 0; plotIdx < this.m_plots.length; plotIdx++)
            {
               plot = this.m_plots[plotIdx] as Plot;
               if(plot.isWithered() || plot.isGrown())
               {
                  plot.setFullGrown();
               }
            }
            Global.hud.iconQueue.removeIconByName("UnwitherOptimization");
         }
         else
         {
            this.onFailedPerform();
         }
      }
      
      override public function canUse() : Boolean
      {
         var plotIdx:int = 0;
         var minPlots:Number = NaN;
         var witherCount:int = 0;
         var response:Boolean = true;
         var currentUserId:String = Global.player.uid;
         if(this.m_targetedUserId == "" || this.m_targetedUserId == currentUserId)
         {
            for(plotIdx = 0; plotIdx < this.m_plots.length; plotIdx++)
            {
               if(this.m_plots[plotIdx].isWithered())
               {
                  witherCount++;
               }
            }
            minPlots = 0;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               minPlots = getItem().getNumberFromDataSource("minPlots");
            }
            else
            {
               minPlots = Number(getItem().xml.minPlots);
            }
            response = Boolean(witherCount) && Global.experimentManager.getExperimentVariant("fv_unwither_optimization") > 0 || witherCount >= minPlots;
         }
         else
         {
            response = true;
         }
         return response;
      }
      
      override public function onFailedPerform() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","UnwitherInvalid"),GenericPopup.TYPE_OK,null,"unwither_invalid",true);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         this.m_targetedUserId = userID;
         super.consume(isGift,allowReshopping,userID,isFree,storageId);
      }
   }
}

