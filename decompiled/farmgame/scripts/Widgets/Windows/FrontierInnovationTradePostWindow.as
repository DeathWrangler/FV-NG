package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FrontierInnovationTradePostFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationTradePostWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private static const FEATURE_NAME:String = "FrontierInnovation";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const SIZE_MC:String = "size_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const CLOSE_BT:String = "close_bt";
      
      private var m_tradePostFrame:FrontierInnovationTradePostFrame;
      
      private var m_count:ZwTextField;
      
      private var m_isEA:Boolean;
      
      private var m_closeBt:FarmButton;
      
      private var m_sizeMc:MovieClip;
      
      private var patternSlot:RegExp = /\d/;
      
      internal var managerObject:Object;
      
      public function FrontierInnovationTradePostWindow(featureBuiilding:FeatureBuilding = null)
      {
         this.managerObject = this.manager;
         var dialogURL:String = this.manager.getTradePostDialogUrl();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_DRAGONVALLEY);
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         var tutorailFeatureName:String = FEATURE_NAME + "TradePost";
         super(tutorailFeatureName,dialogURL,totalScenes);
      }
      
      protected function onClick() : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
         var count:Number = NaN;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CARIBBEAN);
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Trading Post"));
         }
         if(m_window.hasOwnProperty(this.COUNT_TF))
         {
            count = this.manager.TRADE_POST_CAPACITY - this.manager.getTradePostNonEmptySlotCount();
            addWidget(this.m_count = new ZwTextField(m_window[this.COUNT_TF],"Trading Slots Available: " + count));
            this.m_count.visible = true;
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_sizeMc = m_window.size_mc as MovieClip;
            this.m_sizeMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_tradePostFrame = new FrontierInnovationTradePostFrame(m_window[this.SLOTS_MC],this.m_featureName,this);
            this.m_tradePostFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],this.TEXT_WHATISTHIS,this.howDoesThisWorkClick));
         }
      }
      
      public function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function getSlotNumber(slotName:String) : int
      {
         var result:Object = this.patternSlot.exec(slotName);
         return int(result[0]);
      }
      
      public function allocateEmptySlotInTradePost(emptySlot:int, R1:String, R2:String) : void
      {
         this.m_tradePostFrame.refresh();
      }
      
      public function refreshTradePostFrame() : void
      {
         var count:int = this.manager.TRADE_POST_CAPACITY - this.manager.getTradePostNonEmptySlotCount();
         this.m_count.text = "Trading Slots Available: " + count;
         this.m_tradePostFrame.refresh();
      }
      
      override public function close() : void
      {
         if(this.manager.m_BarnWindow)
         {
            this.manager.m_BarnWindow.untintWindow();
            this.manager.m_BarnWindow.enableInput = true;
            this.manager.m_BarnWindow.refreshWindow();
         }
         super.close();
      }
      
      private function get manager() : FrontierInnovationManager
      {
         return FrontierInnovationManager.getInstance(FEATURE_NAME);
      }
   }
}

