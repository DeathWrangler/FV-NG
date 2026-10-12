package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmersMarketInnovationSalesWindow extends GenericOrderBoardWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 6;
      
      private static const FEATURE_TRACKING:String = "FarmersMarket2020Innovation";
      
      private static const FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      private static const QTY_PRODUCE_CHANGE:int = 20;
      
      private static const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var sell_qty:int = 0;
      
      private const BASE_PRICE:int = 160;
      
      private var m_selling_price:int = 0;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_timer:Timer;
      
      private var m_news_pane:MovieClip;
      
      private var m_produce_pane:MovieClip;
      
      private var m_sell_pane:MovieClip;
      
      private var m_price_sticker_tf:ZwTextField;
      
      private var m_produce_icon:FarmIcon;
      
      private var m_increase_bt:FarmButton;
      
      private var m_reduce_bt:FarmButton;
      
      private var m_sell_bt:FarmAnimatedTextButton;
      
      private var m_sellqty_tf:ZwTextField;
      
      private var m_total_earning_tf:ZwTextField;
      
      private var m_coins_icon:FarmIcon;
      
      private var m_produce_count_tf:ZwTextField;
      
      private var m_news:Object;
      
      private var m_totalscore_mc:MovieClip;
      
      private var m_totalbrief_tf:ZwTextField;
      
      private var m_total_score_tf:ZwTextField;
      
      private var m_news_overlay:MovieClip;
      
      private var m_news_content_tf:ZwTextField;
      
      private var m_news_headline2_tf:ZwTextField;
      
      private var m_news_headline_tf:ZwTextField;
      
      private var m_price_timer_tf:ZwTextField;
      
      private var m_sellprice_tf:ZwTextField;
      
      private var m_price_diff_tf:ZwTextField;
      
      private var m_percentage_mc:MovieClip;
      
      private var m_uparrow:MovieClip;
      
      private var m_downarrow:MovieClip;
      
      private var m_stock_slots:Array = [];
      
      private var m_sell_slots:Array = [];
      
      private var m_loadingmarket_tf:ZwTextField;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_minitutorial_frame:ZwFrame;
      
      private var m_mini_tutorial_mc:MovieClip;
      
      public function FarmersMarketInnovationSalesWindow(featureName:String = "FarmersMarket2020Innovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,this.manager,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var sell_price:int = 0;
         var bestprice_sticker:MovieClip = null;
         var m_stock_frame:MovieClip = null;
         var index:int = 0;
         var stockName:String = null;
         var m_sell_frame:MovieClip = null;
         var sellName:String = null;
         var i:int = 0;
         var buttonName:String = null;
         super.postLoadComplete();
         this.visible = true;
         tintWindow();
         this.enableInput = false;
         this.sell_qty = 0;
         this.m_news = this.manager.getNewsContent();
         this.m_selling_price = this.manager.currentSellingPrice;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"MARKET SPACE"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Catch on headlines to estimate the rate change and make the most out of your hard earned produce!"));
         }
         if(m_window.hasOwnProperty("loadingmarket_tf"))
         {
            addWidget(this.m_loadingmarket_tf = new ZwTextField(m_window["loadingmarket_tf"],"  Setting Up Market..."));
            this.m_loadingmarket_tf.visible = true;
         }
         if(m_window.hasOwnProperty("farmvilletimes_pane"))
         {
            this.m_news_pane = m_window["farmvilletimes_pane"] as MovieClip;
            if(this.m_news_pane.hasOwnProperty("farmvilletimes_tf"))
            {
               addWidget(new ZwTextField(this.m_news_pane["farmvilletimes_tf"],"FARMVILLE TIMES"));
            }
            if(this.m_news_pane.hasOwnProperty("flashnews_tf"))
            {
               addWidget(this.m_news_headline_tf = new ZwTextField(this.m_news_pane["flashnews_tf"],this.m_news["headline"]));
            }
            if(this.m_news_pane.hasOwnProperty("knowmore_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_news_pane["knowmore_bt"],"Know More",this.onKnowMoreClick));
            }
            this.m_news_pane.visible = true;
         }
         if(m_window.hasOwnProperty("marketstand"))
         {
            this.m_produce_pane = m_window["marketstand"] as MovieClip;
            sell_price = this.manager.currentSellingPrice;
            if(this.m_produce_pane.hasOwnProperty("bestprice_sticker"))
            {
               bestprice_sticker = this.m_produce_pane["bestprice_sticker"] as MovieClip;
               bestprice_sticker.visible = true;
               if(bestprice_sticker.hasOwnProperty("bestprice_sticker_tf"))
               {
                  addWidget(this.m_price_sticker_tf = new ZwTextField(bestprice_sticker["bestprice_sticker_tf"],""));
               }
            }
            if(this.m_produce_pane.hasOwnProperty("produce_icon"))
            {
               this.m_produce_icon = new FarmIcon(this.m_produce_pane["produce_icon"]);
               this.m_produce_icon.loadIcon(this.manager.currentWeekSmallIcon);
            }
            if(this.m_produce_pane.hasOwnProperty("sellingprice_tf"))
            {
               addWidget(this.m_sellprice_tf = new ZwTextField(this.m_produce_pane["sellingprice_tf"],sell_price.toString()));
            }
            if(this.m_produce_pane.hasOwnProperty("producecount_tf"))
            {
               addWidget(this.m_produce_count_tf = new ZwTextField(this.m_produce_pane["producecount_tf"]));
            }
            if(this.m_produce_pane.hasOwnProperty("ratechange_tf"))
            {
               addWidget(this.m_price_timer_tf = new ZwTextField(this.m_produce_pane["ratechange_tf"]));
               this.m_price_timer_tf.text = "Price changes in: " + HUD.getformattedTimeLeft(this.manager.currentNewsTimeRemaining());
            }
            if(this.m_produce_pane.hasOwnProperty("percentage_mc"))
            {
               this.m_percentage_mc = this.m_produce_pane["percentage_mc"] as MovieClip;
               if(this.m_percentage_mc.hasOwnProperty("uparrow"))
               {
                  this.m_uparrow = this.m_percentage_mc["uparrow"] as MovieClip;
               }
               if(this.m_percentage_mc.hasOwnProperty("downarrow"))
               {
                  this.m_downarrow = this.m_percentage_mc["downarrow"] as MovieClip;
               }
               if(this.m_percentage_mc.hasOwnProperty("pluspercent_tf"))
               {
                  addWidget(this.m_price_diff_tf = new ZwTextField(this.m_percentage_mc["pluspercent_tf"]));
               }
               this.updateRateChangeDetails();
            }
            this.m_produce_pane.visible = true;
         }
         if(m_window.hasOwnProperty("marketstand1"))
         {
            this.m_sell_pane = m_window["marketstand1"] as MovieClip;
            if(this.m_sell_pane.hasOwnProperty("addd_bt"))
            {
               addWidget(this.m_increase_bt = new FarmButton(this.m_sell_pane["addd_bt"],this.onIncreaseQtyClick));
            }
            if(this.m_sell_pane.hasOwnProperty("reduce_bt"))
            {
               addWidget(this.m_reduce_bt = new FarmButton(this.m_sell_pane["reduce_bt"],this.onReduceQtyClick));
            }
            if(this.m_sell_pane.hasOwnProperty("sell_bt"))
            {
               addWidget(this.m_sell_bt = new FarmAnimatedTextButton(this.m_sell_pane["sell_bt"],"Sell",this.onSellButtonClick));
            }
            if(this.m_sell_pane.hasOwnProperty("totalearningcount_tf"))
            {
               addWidget(this.m_total_earning_tf = new ZwTextField(this.m_sell_pane["totalearningcount_tf"],"---"));
            }
            if(this.m_sell_pane.hasOwnProperty("addandreduce_tf"))
            {
               addWidget(this.m_sellqty_tf = new ZwTextField(this.m_sell_pane["addandreduce_tf"],"000"));
            }
            if(this.m_sell_pane.hasOwnProperty("totalearning_tf"))
            {
               addWidget(new ZwTextField(this.m_sell_pane["totalearning_tf"],"You earn"));
            }
            if(this.m_sell_pane.hasOwnProperty("coins_icon"))
            {
               this.m_coins_icon = new FarmIcon(this.m_sell_pane["coins_icon"]);
            }
            this.updateQtyButtonStates();
            this.m_sell_pane.visible = true;
         }
         if(m_window.hasOwnProperty("totalscore"))
         {
            this.m_totalscore_mc = m_window["totalscore"] as MovieClip;
            this.m_totalscore_mc.visible = true;
            if(this.m_totalscore_mc.hasOwnProperty("totalscorecount_tf"))
            {
               addWidget(this.m_total_score_tf = new ZwTextField(this.m_totalscore_mc["totalscorecount_tf"],this.manager.getTotalGoldCoins().toString()));
               this.m_total_score_tf.visible = true;
            }
            if(this.m_totalscore_mc.hasOwnProperty("totalscore_brief"))
            {
               addWidget(this.m_totalbrief_tf = new ZwTextField(this.m_totalscore_mc["totalscore_brief"]));
               this.m_totalbrief_tf.text = "Need " + (10000 - this.manager.getDayPoints()).toString() + " to get today\'s reward!";
               this.m_totalbrief_tf.visible = this.manager.getDayPoints() >= 10000 ? false : true;
            }
         }
         if(m_window.hasOwnProperty("news_slot"))
         {
            this.m_news_overlay = m_window["news_slot"] as MovieClip;
            this.m_news_overlay.visible = false;
            if(this.m_news_overlay.hasOwnProperty("close1_bt"))
            {
               addWidget(new FarmButton(this.m_news_overlay["close1_bt"],this.onCloseNewsOverlayClick));
            }
            if(this.m_news_overlay.hasOwnProperty("news1_tf"))
            {
               addWidget(this.m_news_content_tf = new ZwTextField(this.m_news_overlay["news1_tf"],this.m_news["paragraph"]));
            }
            if(this.m_news_overlay.hasOwnProperty("headline_tf"))
            {
               addWidget(this.m_news_headline2_tf = new ZwTextField(this.m_news_overlay["headline_tf"],this.m_news["headline"]));
            }
         }
         if(m_window.hasOwnProperty("produces_stock"))
         {
            m_stock_frame = m_window["produces_stock"] as MovieClip;
            m_stock_frame.visible = true;
            for(index = 0; index < 3; index++)
            {
               stockName = "stock_produce" + index.toString();
               if(m_stock_frame.hasOwnProperty(stockName))
               {
                  this.m_stock_slots[index] = new FarmIcon(m_stock_frame[stockName],this.manager.currentWeekStockIcon);
                  this.m_stock_slots[index].visible = false;
                  this.m_stock_slots[index].setIconSize(110,98);
               }
            }
         }
         if(m_window.hasOwnProperty("produces_sell"))
         {
            m_sell_frame = m_window["produces_sell"] as MovieClip;
            m_sell_frame.visible = true;
            for(index = 0; index < 3; index++)
            {
               sellName = "sell_produce" + index.toString();
               if(m_sell_frame.hasOwnProperty(sellName))
               {
                  this.m_sell_slots[index] = new FarmIcon(m_sell_frame[sellName],this.manager.currentWeekSellIcon);
                  this.m_sell_slots[index].visible = false;
                  this.m_sell_slots[index].setIconSize(105,95);
               }
            }
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("mini_tutorial_mc"))
         {
            this.m_mini_tutorial_mc = m_window["mini_tutorial_mc"] as MovieClip;
            this.m_minitutorial_frame = addWidget(new ZwFrame(this.m_mini_tutorial_mc),false) as ZwFrame;
            if(this.m_mini_tutorial_mc.hasOwnProperty("okay_bt"))
            {
               this.m_minitutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_mini_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_mini_tutorial_mc["okay_bt"].visible = true;
            }
            this.m_mini_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            if(m_window["tutorial_mc"])
            {
               for(i = 0; i <= 4; i++)
               {
                  buttonName = "okaym" + (i + 1).toString() + "_bt";
                  if(m_window["tutorial_mc"].hasOwnProperty(buttonName))
                  {
                     if(i == 3)
                     {
                        this.m_tutorialButtons[i] = new FarmButton(m_window["tutorial_mc"][buttonName]);
                     }
                     else
                     {
                        this.m_tutorialButtons[i] = new FarmAnimatedTextButton(m_window["tutorial_mc"][buttonName]);
                     }
                     this.m_tutorialButtons[i].visible = false;
                  }
               }
            }
         }
         this.startTimer();
         this.updateProduceIcons();
         this.updatePriceSticker();
      }
      
      protected function preSwitchChangesMain(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmButton = null;
         var button4:FarmAnimatedTextButton = null;
         var button5:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Great!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Okay!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Cool!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
               break;
            case 3:
               button3 = this.m_tutorialButtons[3] as FarmButton;
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(3);
               (m_tutorial.element as MovieClip).gotoAndStop(4);
               break;
            case 4:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "Sell";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(4);
               (m_tutorial.element as MovieClip).gotoAndStop(5);
               break;
            case 5:
               button5 = this.m_tutorialButtons[5] as FarmAnimatedTextButton;
               button5.text = "Alright!";
               button5.visible = true;
               button5.callback = this.onTutorialOkayButtonClickMain;
               this.hideOtherTutorialButtonsExpect(5);
               (m_tutorial.element as MovieClip).gotoAndStop(6);
         }
      }
      
      protected function onTutorialOkayButtonClickMain(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes - 1)
         {
            this.preSwitchChangesMain(tutorialSceneNumber);
            ++tutorialSceneNumber;
         }
         else
         {
            hideTutorial();
            this.manager.updateMarketTutorialFlag();
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.preSwitchChangesMain(4);
            }
            this.close();
         }
      }
      
      private function hideOtherTutorialButtonsExpect(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      public function showMainTutorial() : void
      {
         super.showTutorial();
         this.preSwitchChangesMain(0);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_minitutorial_frame)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_minitutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_minitutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_minitutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_minitutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_minitutorial_frame.visible = false;
         }
      }
      
      private function updateProduceIcons() : void
      {
         var produce:int = this.manager.getCurrentProduceQty();
         var capacity:int = this.manager.currentStorageCapacity;
         this.m_stock_slots[0].visible = produce - this.sell_qty > 0;
         this.m_stock_slots[1].visible = produce - this.sell_qty > 1 / 3 * capacity;
         this.m_stock_slots[2].visible = produce - this.sell_qty == capacity;
         this.m_sell_slots[0].visible = this.sell_qty > 0;
         this.m_sell_slots[1].visible = this.sell_qty > 1 / 3 * capacity;
         this.m_sell_slots[2].visible = this.sell_qty != 0 && this.sell_qty == capacity;
      }
      
      private function updatePriceSticker() : void
      {
         if(this.m_price_sticker_tf)
         {
            this.m_selling_price = this.manager.currentSellingPrice;
            if(this.m_selling_price >= 60 && this.m_selling_price <= 150)
            {
               this.m_price_sticker_tf.text = "Low\nDemand!";
            }
            else if(this.m_selling_price >= 160 && this.m_selling_price <= 250)
            {
               this.m_price_sticker_tf.text = "Stable\nDemand";
            }
            else if(this.m_selling_price >= 260 && this.m_selling_price <= 350)
            {
               this.m_price_sticker_tf.text = "High\nDemand!";
            }
         }
      }
      
      private function updateRateChangeDetails() : void
      {
         var sell_price:int = this.manager.currentSellingPrice;
         var percent:Number = (sell_price - this.BASE_PRICE) / this.BASE_PRICE * 100;
         if(percent > 0)
         {
            if(this.m_uparrow)
            {
               this.m_uparrow.visible = true;
            }
            if(this.m_downarrow)
            {
               this.m_downarrow.visible = false;
            }
         }
         else if(percent < 0)
         {
            if(this.m_uparrow)
            {
               this.m_uparrow.visible = false;
            }
            if(this.m_downarrow)
            {
               this.m_downarrow.visible = true;
            }
         }
         if(this.m_price_diff_tf)
         {
            this.m_price_diff_tf.text = percent.toString() + "%";
         }
      }
      
      private function onIncreaseQtyClick(e:Event = null) : void
      {
         this.manager.increaseProduceQty();
         var currentProduce:int = this.manager.getCurrentProduceQty();
         var maxCapacity:int = this.manager.currentStorageCapacity;
         var remaining:int = currentProduce - this.sell_qty;
         if(remaining == 0)
         {
            if(this.m_increase_bt)
            {
               this.m_increase_bt.enabled = false;
            }
         }
         else if(remaining < QTY_PRODUCE_CHANGE && remaining != 0)
         {
            this.sell_qty += remaining;
         }
         else
         {
            this.sell_qty += QTY_PRODUCE_CHANGE;
         }
         this.displaySellQty();
         this.updateProduceIcons();
         if(this.sell_qty > 0 && Boolean(this.m_reduce_bt))
         {
            this.m_reduce_bt.enabled = true;
         }
         if(this.sell_qty == currentProduce)
         {
            if(this.m_increase_bt)
            {
               this.m_increase_bt.enabled = false;
            }
         }
      }
      
      private function onReduceQtyClick(e:Event = null) : void
      {
         this.manager.reduceProduceQty();
         var currentProduce:int = this.manager.getCurrentProduceQty();
         var remaining:int = this.sell_qty % QTY_PRODUCE_CHANGE;
         if(this.sell_qty != 0)
         {
            if(remaining != 0)
            {
               this.sell_qty -= remaining;
            }
            else
            {
               this.sell_qty -= QTY_PRODUCE_CHANGE;
            }
         }
         this.displaySellQty();
         this.updateProduceIcons();
         if(this.sell_qty < currentProduce && Boolean(this.m_increase_bt))
         {
            this.m_increase_bt.enabled = true;
         }
         if(this.sell_qty <= 0 && Boolean(this.m_reduce_bt))
         {
            this.m_reduce_bt.enabled = false;
         }
      }
      
      public function showLoaderText() : void
      {
         if(this.m_loadingmarket_tf)
         {
            this.m_loadingmarket_tf.visible = true;
         }
      }
      
      public function hideLoaderText() : void
      {
         if(Boolean(m_window) && Boolean(this.m_loadingmarket_tf))
         {
            this.m_loadingmarket_tf.visible = false;
         }
      }
      
      private function displaySellQty() : void
      {
         var qty_text:String = "";
         if(this.sell_qty < 10)
         {
            qty_text = "00" + this.sell_qty.toString();
         }
         else if(this.sell_qty < 100)
         {
            qty_text = "0" + this.sell_qty.toString();
         }
         else
         {
            qty_text = this.sell_qty.toString();
         }
         if(this.sell_qty > 0 && Boolean(this.m_sell_bt))
         {
            this.m_sell_bt.enabled = true;
         }
         if(this.m_sellqty_tf)
         {
            this.m_sellqty_tf.text = qty_text;
         }
         if(this.m_total_earning_tf)
         {
            this.m_total_earning_tf.text = this.sell_qty == 0 ? "----" : (this.sell_qty * this.manager.currentSellingPrice).toString();
         }
      }
      
      private function updateQtyButtonStates() : void
      {
         var currentProduce:int = 0;
         if(Boolean(this.m_increase_bt) && Boolean(this.m_reduce_bt) && Boolean(this.m_sell_bt))
         {
            currentProduce = this.manager.getCurrentProduceQty();
            this.m_increase_bt.enabled = currentProduce > 0 ? true : false;
            this.m_reduce_bt.enabled = false;
            this.m_sell_bt.enabled = this.sell_qty > 0 && currentProduce >= QTY_PRODUCE_CHANGE ? true : false;
         }
         if(this.m_produce_count_tf)
         {
            this.m_produce_count_tf.text = this.manager.getCurrentProduceQty().toString() + "/" + this.manager.currentStorageCapacity.toString();
         }
         if(this.m_total_earning_tf)
         {
            this.m_total_earning_tf.text = "----";
         }
      }
      
      public function onCloseNewsOverlayClick(e:Event = null) : void
      {
         if(this.m_news_overlay)
         {
            this.m_news_overlay.visible = false;
         }
      }
      
      public function onSellButtonClick(e:Event = null) : void
      {
         this.tintWindow();
         this.enableInput = false;
         var confirmationMessage:String = "Do you want to sell " + this.sell_qty.toString() + " " + this.manager.getWeekProduceName(this.sell_qty) + " for " + this.sell_qty * this.manager.currentSellingPrice + " Market Coins?";
         UI.displayMessage(confirmationMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteClose,"",true);
      }
      
      protected function onConfirmCompleteClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.manager.sellProduce();
         }
         else
         {
            FarmStatsManager.count(FEATURE_NAME,"CancelSell");
            this.untintWindow();
            this.enableInput = true;
         }
      }
      
      private function onKnowMoreClick(e:Event = null) : void
      {
         if(this.m_news_overlay)
         {
            if(Boolean(this.m_news_content_tf) && Boolean(this.m_news_headline2_tf))
            {
               this.m_news_content_tf.text = this.m_news["paragraph"];
               this.m_news_headline2_tf.text = this.m_news["headline"];
            }
            this.m_news_overlay.visible = true;
         }
         FarmStatsManager.count(FEATURE_TRACKING,"news","open");
      }
      
      private function get manager() : FarmersMarketInnovationManager
      {
         return FarmersMarketInnovationManager.getInstance(FEATURE_NAME);
      }
      
      override public function refreshWindow() : void
      {
         if(m_window)
         {
            this.manager.resetProduceSellQty();
            this.updateQtyButtonStates();
            if(this.sell_qty)
            {
               this.sell_qty = 0;
            }
            this.updateProduceIcons();
            if(this.m_sellqty_tf)
            {
               this.m_sellqty_tf.text = "000";
            }
            if(this.m_total_score_tf)
            {
               this.m_total_score_tf.text = this.manager.getTotalGoldCoins().toString();
            }
            if(this.m_sell_bt)
            {
               this.m_sell_bt.enabled = this.sell_qty > 0 ? true : false;
            }
            if(this.m_sellprice_tf)
            {
               this.m_sellprice_tf.text = this.manager.currentSellingPrice.toString();
            }
            this.updateRateChangeDetails();
            if(Boolean(this.m_news_headline_tf) && Boolean(this.m_news_content_tf))
            {
               this.m_news_headline_tf.text = this.m_news["headline"];
               this.m_news_content_tf.text = this.m_news["paragraph"];
               if(this.m_news_headline2_tf)
               {
                  this.m_news_headline2_tf.text = this.m_news["headline"];
               }
            }
            this.updatePriceSticker();
            if(this.m_totalbrief_tf)
            {
               this.m_totalbrief_tf.text = "Need " + (10000 - this.manager.getDayPoints()).toString() + " to get today\'s reward!";
               this.m_totalbrief_tf.visible = this.manager.getDayPoints() >= 10000 ? false : true;
            }
         }
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.m_timer)
         {
            this.refreshNewsTimerText();
         }
      }
      
      private function refreshNewsTimerText() : void
      {
         if(m_window)
         {
            if(this.manager.hasNewsSlotTimeExpired())
            {
               this.enableInput = false;
               this.close();
            }
            if(Boolean(this.m_price_timer_tf) && Boolean(this.m_timer))
            {
               this.m_price_timer_tf.text = "Price changes in: " + HUD.getformattedTimeLeft(this.manager.currentNewsTimeRemaining());
            }
         }
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
      
      override public function close() : void
      {
         this.stopTimer();
         this.manager.resetProduceSellQty();
         if(this.sell_qty)
         {
            this.sell_qty = 0;
         }
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.refreshTaskFrame();
            this.manager.mainWindow.refreshWindow();
         }
         super.close();
         FarmStatsManager.count("FarmersMarketMainWindow","Main_UI","close_window");
      }
   }
}

