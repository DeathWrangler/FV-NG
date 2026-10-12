package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.MoneyTree2017Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MoneyTree2017Window extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const DAILY_HARVEST_MC:String = "daily_harvest_mc";
      
      protected var m_featureName:String;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const TIMER_TF:String = "info_tf";
      
      private const BODY_TF:String = "info_1_tf";
      
      private const BODY2_TF:String = "info_2_tf";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const SALE_END_MC:String = "Sale_end_mc";
      
      private var m_saleEndMc:MovieClip;
      
      private const TREE1_MC:String = "tree_1_mc";
      
      private const TREE2_MC:String = "tree_2_mc";
      
      private var m_tree1_mc:MovieClip;
      
      private var m_tree1Buy_bt:FarmAnimatedTextButton;
      
      private var m_tree2_mc:MovieClip;
      
      private var m_tree2Buy_bt:FarmAnimatedTextButton;
      
      private var m_dailyHarvestMC:MovieClip;
      
      private var m_max_mc:MovieClip;
      
      private const MAX_MC:String = "max_mc";
      
      private const SIZE_MC:String = "size_mc";
      
      private var m_size_mc:MovieClip;
      
      private var m_timer:Timer;
      
      private var m_itemName:String = "";
      
      private var m_saleEnd_tf:ZwTextField;
      
      public function MoneyTree2017Window(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(this.m_featureName,assetPath,numOfTutorialPages,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_Title")));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_body")));
         }
         if(m_window.hasOwnProperty(this.BODY2_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY2_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_body2")));
         }
         if(m_window.hasOwnProperty(DAILY_HARVEST_MC))
         {
            this.m_dailyHarvestMC = m_window[DAILY_HARVEST_MC] as MovieClip;
            this.m_dailyHarvestMC.visible = true;
         }
         if(m_window.hasOwnProperty(this.MAX_MC))
         {
            this.m_max_mc = m_window[this.MAX_MC] as MovieClip;
            this.m_max_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_size_mc = m_window[this.SIZE_MC] as MovieClip;
            this.m_size_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SALE_END_MC))
         {
            this.m_saleEndMc = m_window[this.SALE_END_MC] as MovieClip;
            this.m_saleEndMc.visible = true;
            if(this.m_saleEndMc.hasOwnProperty(this.TIMER_TF))
            {
               addWidget(this.m_saleEnd_tf = new ZwTextField(this.m_saleEndMc[this.TIMER_TF],"Sale ends in " + this.manager.getFeatureEndDaysLeftText() + " HURRY!"));
            }
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.TREE1_MC))
         {
            this.m_tree1_mc = m_window[this.TREE1_MC] as MovieClip;
            this.m_tree1_mc.visible = true;
            if(this.m_tree1_mc.hasOwnProperty("buy_bt"))
            {
               this.m_tree1Buy_bt = new FarmAnimatedTextButton(this.m_tree1_mc["buy_bt"],"Buy",this.onTree1Call);
            }
         }
         if(m_window.hasOwnProperty(this.TREE2_MC))
         {
            this.m_tree2_mc = m_window[this.TREE2_MC] as MovieClip;
            this.m_tree2_mc.visible = true;
            if(this.m_tree2_mc.hasOwnProperty("buy_bt"))
            {
               this.m_tree2Buy_bt = new FarmAnimatedTextButton(this.m_tree2_mc["buy_bt"],"Buy",this.onTree2Call);
            }
         }
         this.startTimer();
      }
      
      public function onTree1Call(e:Event) : void
      {
         this.m_itemName = "silverbillsprosperytree";
         tintWindow();
         enableInput = false;
         this.manager.buyTree(this.m_itemName);
      }
      
      public function onTree2Call(e:Event) : void
      {
         this.m_itemName = "goldbillsprosperytree";
         tintWindow();
         enableInput = false;
         this.manager.buyTree(this.m_itemName);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      override public function refreshWindow() : void
      {
      }
      
      override public function untintWindow() : void
      {
         this.refreshWindow();
         super.untintWindow();
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.manager.mainWindow = null;
         super.close();
      }
      
      private function get manager() : MoneyTree2017Manager
      {
         return MoneyTree2017Manager.getInstance(this.m_featureName);
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         if(this.m_saleEnd_tf)
         {
            this.m_saleEnd_tf.text = "Sale ends in " + this.manager.getFeatureEndDaysLeftText() + " HURRY!";
         }
      }
   }
}

