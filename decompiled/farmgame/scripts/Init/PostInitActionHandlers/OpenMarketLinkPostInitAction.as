package Init.PostInitActionHandlers
{
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.OpenMarketIdleTask;
   import Display.UI;
   
   public class OpenMarketLinkPostInitAction extends AbstractPostInitAction
   {
      
      private const MARKET_CATEGORY_SPECIAL_VARIANT:int = 2;
      
      private const MARKET_CATEGORY_LIMITED_VARIANT:int = 3;
      
      public function OpenMarketLinkPostInitAction()
      {
         super();
      }
      
      override public function execute() : void
      {
         var marketType:String = null;
         var marketSubType:String = null;
         var marketOnIdle:Boolean = false;
         var refSource:String = null;
         var variant:int = 0;
         var category:String = null;
         if(GlobalEngine.getFlashVar("openMarket") == "true")
         {
            marketType = GlobalEngine.getFlashVar("marketType") as String;
            marketSubType = GlobalEngine.getFlashVar("marketSubType") as String;
            marketOnIdle = GlobalEngine.getFlashVar("marketOnIdle") as String == "true";
            refSource = GlobalEngine.getFlashVar("ref") as String;
            variant = Global.experimentManager.getExperimentVariant("fv_marketplace_autopop");
            if(marketOnIdle)
            {
               if(variant >= this.MARKET_CATEGORY_SPECIAL_VARIANT)
               {
                  category = "";
                  if(variant == this.MARKET_CATEGORY_SPECIAL_VARIANT)
                  {
                     category = "special";
                  }
                  else if(variant == this.MARKET_CATEGORY_LIMITED_VARIANT)
                  {
                     category = "limited";
                  }
                  IdleTaskQueue.getInstance().addTask(new OpenMarketIdleTask(7,category));
               }
            }
            else
            {
               UI.displayMarketDialog(refSource,marketType,null,marketSubType);
            }
         }
         m_isFinished = true;
      }
   }
}

