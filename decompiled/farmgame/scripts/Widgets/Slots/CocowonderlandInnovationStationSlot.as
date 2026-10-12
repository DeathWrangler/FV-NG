package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Managers.OrderBoard.CocowonderlandInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CocowonderlandInnovationStationIngredientsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CocowonderlandInnovationStationSlot extends ZwSlotFrame
   {
      
      private static const STATION_BT:String = "station_bt";
      
      private static const STATIONNAME_TF:String = "station_name_tf";
      
      private static const STATIONSUBTEXT_TF:String = "station_subtext_tf";
      
      private static const STATIONLOCK_MC:String = "station_lock_mc";
      
      private static const STATIONINGREDIENTS_MC:String = "all_order_ing_items_mc";
      
      private static const FAILSUBTEXT_TF:String = "fail_subtext_tf";
      
      private static const COINSADD_TF:String = "plus_coins_tf";
      
      private static const ICON_COINS_IMG:String = "icon_coins_img";
      
      private static const STATIONICON_MC:String = "icon_station_mc";
      
      private static const STATIONHIGHLIGHT_MC:String = "station_highlight_mc";
      
      private static const COOK_PROGRESS_MC:String = "cook_progress_mc";
      
      private static const EXCLAMATION_MC:String = "exclamation_ani_mc";
      
      private static const PROGRESS_FILL_MC:String = "progress_fill_mc";
      
      private static const PROGRESS_TEXT_TF:String = "cook_timer_tf";
      
      private static const COIN_SUCCESS_TF:String = "coin_success_tf";
      
      private static const SUCCESS_TF:String = "success_tf";
      
      private static const FAIL_TF:String = "fail_tf";
      
      private static const SUCCESS_ICON_MC:String = "success_icon_mc";
      
      private static const BAR_LENGTH:int = 157;
      
      private static const WEEK_COUNT:int = 6;
      
      private static const STATION_1_URL:String = "assets/dialogs/cocoland/innovation/station_bg_locked_1.png";
      
      private static const STATION_2_URL:String = "assets/dialogs/cocoland/innovation/station_bg_locked_2.png";
      
      private var m_window:CocowonderlandInnovationMainWindow;
      
      private const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private const STATION_ANIMATION_FRAME_ARRAY:Array;
      
      private const STATION_DISABLED_FRAME_ARRAY:Array;
      
      private var m_station_bt:FarmAnimatedTextButton;
      
      private var m_stationName_tf:ZwTextField;
      
      private var m_stationSubtext_tf:ZwTextField;
      
      private var m_stationLock_mc:FarmIcon;
      
      private var m_failSubtext_tf:ZwTextField;
      
      private var m_coinsGrantQty_tf:ZwTextField;
      
      private var m_coinsIconImg_mc:MovieClip;
      
      private var m_iconStation_mc:MovieClip;
      
      private var m_iconStation5_grey_mc:MovieClip;
      
      private var m_stationHighlight_mc:MovieClip;
      
      private var m_cook_progress_mc:MovieClip;
      
      private var m_exclamation_mc:MovieClip;
      
      private var m_progress_fill_mc:MovieClip;
      
      private var m_progress_text_tf:ZwTextField;
      
      private var m_coin_success_tf:ZwTextField;
      
      private var m_success_tf:ZwTextField;
      
      private var m_fail_tf:ZwTextField;
      
      private var m_success_icon_mc:FarmIcon;
      
      private var m_StationAnimationMC_Array:Array;
      
      private var m_slotNumber:Number;
      
      private var m_cookTimeStart:int;
      
      private var m_cookingStarted:Boolean = false;
      
      private var m_cookTimer:Timer;
      
      private var m_cookedOrder:String;
      
      private var m_lastFill:* = 0.002;
      
      private var m_ingredientFrame:CocowonderlandInnovationStationIngredientsFrame;
      
      public function CocowonderlandInnovationStationSlot(element:DisplayObject, window:CocowonderlandInnovationMainWindow)
      {
         var i:int = 0;
         var slotForTheWeek:String = null;
         this.STATION_ANIMATION_FRAME_ARRAY = [50,75,80,66,40,2];
         this.STATION_DISABLED_FRAME_ARRAY = [425,411,425,256,301,14];
         this.m_StationAnimationMC_Array = [];
         super(element);
         this.m_window = window;
         this.visible = true;
         if(m_element.hasOwnProperty(STATION_BT))
         {
            addWidget(this.m_station_bt = new FarmAnimatedTextButton(m_element[STATION_BT],"Cook"));
            this.m_station_bt.visible = false;
         }
         if(m_element.hasOwnProperty(STATIONNAME_TF))
         {
            addWidget(this.m_stationName_tf = new ZwTextField(m_element[STATIONNAME_TF]));
            this.m_stationName_tf.visible = false;
         }
         if(m_element.hasOwnProperty(STATIONSUBTEXT_TF))
         {
            addWidget(this.m_stationSubtext_tf = new ZwTextField(m_element[STATIONSUBTEXT_TF]));
            this.m_stationSubtext_tf.visible = false;
         }
         if(m_element.hasOwnProperty(STATIONLOCK_MC))
         {
            addWidget(this.m_stationLock_mc = new FarmIcon(m_element[STATIONLOCK_MC]));
            this.m_stationLock_mc.visible = false;
         }
         if(m_element.hasOwnProperty(STATIONINGREDIENTS_MC))
         {
            this.m_ingredientFrame = new CocowonderlandInnovationStationIngredientsFrame(m_element[STATIONINGREDIENTS_MC],window,this.FEATURE_NAME,this);
            this.m_ingredientFrame.visible = true;
         }
         if(m_element.hasOwnProperty(SUCCESS_TF))
         {
            addWidget(this.m_success_tf = new ZwTextField(m_element[SUCCESS_TF]));
            this.m_success_tf.visible = false;
         }
         if(m_element.hasOwnProperty(FAIL_TF))
         {
            addWidget(this.m_fail_tf = new ZwTextField(m_element[FAIL_TF]));
            this.m_fail_tf.visible = false;
         }
         if(m_element.hasOwnProperty(SUCCESS_ICON_MC))
         {
            addWidget(this.m_success_icon_mc = new FarmIcon(m_element[SUCCESS_ICON_MC]));
            this.m_success_icon_mc.visible = false;
         }
         if(m_element.hasOwnProperty(FAILSUBTEXT_TF))
         {
            addWidget(this.m_failSubtext_tf = new ZwTextField(m_element[FAILSUBTEXT_TF]));
            this.m_failSubtext_tf.visible = false;
         }
         if(m_element.hasOwnProperty(COINSADD_TF))
         {
            addWidget(this.m_coinsGrantQty_tf = new ZwTextField(m_element[COINSADD_TF]));
            this.m_coinsGrantQty_tf.visible = false;
         }
         if(m_element.hasOwnProperty(EXCLAMATION_MC))
         {
            this.m_exclamation_mc = m_element[EXCLAMATION_MC] as MovieClip;
            this.m_exclamation_mc.visible = false;
         }
         if(m_element.hasOwnProperty(ICON_COINS_IMG))
         {
            this.m_coinsIconImg_mc = m_element[ICON_COINS_IMG] as MovieClip;
            this.m_coinsIconImg_mc.visible = false;
         }
         if(m_element.hasOwnProperty(COIN_SUCCESS_TF))
         {
            addWidget(this.m_coin_success_tf = new ZwTextField(m_element[COIN_SUCCESS_TF]));
            this.m_coin_success_tf.visible = false;
         }
         if(m_element.hasOwnProperty(COOK_PROGRESS_MC))
         {
            this.m_cook_progress_mc = m_element[COOK_PROGRESS_MC] as MovieClip;
            if(this.m_cook_progress_mc.hasOwnProperty(PROGRESS_FILL_MC))
            {
               this.m_progress_fill_mc = this.m_cook_progress_mc[PROGRESS_FILL_MC] as MovieClip;
               this.m_progress_fill_mc.visible = false;
            }
            this.m_cook_progress_mc.visible = false;
         }
         if(m_element.hasOwnProperty(PROGRESS_TEXT_TF))
         {
            addWidget(this.m_progress_text_tf = new ZwTextField(m_element[PROGRESS_TEXT_TF],"Ready in 03:00"));
            this.m_progress_text_tf.visible = false;
         }
         if(m_element.hasOwnProperty(STATIONICON_MC))
         {
            this.m_iconStation_mc = m_element[STATIONICON_MC] as MovieClip;
            this.m_iconStation_mc.visible = true;
            for(i = 0; i < WEEK_COUNT; i++)
            {
               slotForTheWeek = "icon_station" + i + "_mc";
               this.m_StationAnimationMC_Array[i] = this.m_iconStation_mc[slotForTheWeek] as MovieClip;
               this.m_StationAnimationMC_Array[i].visible = false;
            }
            if(this.m_iconStation_mc.hasOwnProperty("icon_station5_grey_mc"))
            {
               this.m_iconStation5_grey_mc = this.m_iconStation_mc["icon_station5_grey_mc"] as MovieClip;
               this.m_iconStation5_grey_mc.visible = false;
            }
         }
         if(m_element.hasOwnProperty(STATIONHIGHLIGHT_MC))
         {
            this.m_stationHighlight_mc = m_element[STATIONHIGHLIGHT_MC] as MovieClip;
            this.m_stationHighlight_mc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var stationData:Object = null;
         var weekData:Object = null;
         var curWeek:int = 0;
         var isRedeem:Boolean = false;
         var ingredientCount1:Number = NaN;
         var ingredientArray1:Array = null;
         var ingredient1:String = null;
         var ingredientXML1:XML = null;
         var cookedOrder:String = null;
         var orderXML:XML = null;
         var ingredientCount:Number = NaN;
         var refreshIngredients:Boolean = false;
         var ingredientArray:Array = null;
         var ingredient:String = null;
         var ingredientXML:XML = null;
         var orderXML1:XML = null;
         if(data)
         {
            if(data.hasOwnProperty("questStationSlotNumber"))
            {
               this.m_slotNumber = data["questStationSlotNumber"];
               this.m_stationName_tf.text = "Station " + (this.m_slotNumber + 1).toString();
               this.m_stationName_tf.visible = true;
            }
            this.m_ingredientFrame.visible = true;
            this.m_failSubtext_tf.visible = false;
            this.m_success_tf.visible = false;
            this.m_fail_tf.visible = false;
            this.m_success_icon_mc.visible = false;
            this.m_coinsIconImg_mc.visible = false;
            this.m_coinsGrantQty_tf.visible = false;
            stationData = data["StationData"] as Object;
            weekData = this.manager.getCurrentWeek();
            curWeek = weekData.count - 1;
            if(Boolean(this.m_StationAnimationMC_Array) && Boolean(this.m_StationAnimationMC_Array[curWeek]))
            {
               this.m_StationAnimationMC_Array[curWeek].visible = true;
               if(this.manager.isStationLocked(this.m_slotNumber))
               {
                  if(curWeek == 5)
                  {
                     this.m_iconStation5_grey_mc.visible = true;
                     if(this.m_StationAnimationMC_Array)
                     {
                        this.m_StationAnimationMC_Array[curWeek].visible = false;
                     }
                  }
                  else
                  {
                     this.m_StationAnimationMC_Array[curWeek].gotoAndStop(this.STATION_DISABLED_FRAME_ARRAY[curWeek]);
                     this.m_iconStation5_grey_mc.visible = false;
                  }
               }
            }
            if(this.manager.hasActiveDayExpired())
            {
               isRedeem = false;
               if(Boolean(stationData) && stationData.hasOwnProperty("state"))
               {
                  if(stationData["state"] == CocowonderlandInnovationManager.STATION_STATES[CocowonderlandInnovationManager.STATION_STATE_LOCKED])
                  {
                     if(this.m_slotNumber == 1)
                     {
                        this.m_stationSubtext_tf.text = "Reach Sous Chef level to unlock this station for today.";
                        this.m_stationLock_mc.loadIcon(STATION_1_URL);
                     }
                     else if(this.m_slotNumber == 2)
                     {
                        this.m_stationSubtext_tf.text = "Reach Patissier level to unlock this station for today.";
                        this.m_stationLock_mc.loadIcon(STATION_2_URL);
                     }
                     this.m_stationSubtext_tf.visible = true;
                     this.m_stationLock_mc.visible = true;
                  }
                  else
                  {
                     this.m_stationLock_mc.visible = false;
                     if(stationData.hasOwnProperty("cookTimeStart"))
                     {
                        ingredientCount1 = 0;
                        if(stationData.hasOwnProperty("ingredients"))
                        {
                           ingredientArray1 = [];
                           for each(ingredient1 in stationData["ingredients"])
                           {
                              ingredientXML1 = this.manager.getIngredientXML(ingredient1);
                              if(ingredientXML1)
                              {
                                 ingredientCount1++;
                                 ingredientArray1.push(ingredientXML1);
                              }
                           }
                           this.m_ingredientFrame.setData(ingredientArray1);
                        }
                        this.m_cookTimeStart = stationData["cookTimeStart"];
                        if(this.m_cookTimeStart > 0)
                        {
                           if(this.manager.isCookDone(this.m_slotNumber))
                           {
                              this.m_station_bt.visible = true;
                              this.m_station_bt.text = "redeem";
                              this.m_station_bt.callback = this.onServe;
                              cookedOrder = stationData["cookedOrder"];
                              orderXML = this.manager.getOrderXML(cookedOrder);
                              isRedeem = true;
                              if(stationData.hasOwnProperty("cookedOrder"))
                              {
                                 if(stationData["cookedOrder"] != "")
                                 {
                                    this.m_exclamation_mc.visible = true;
                                    this.m_station_bt.text = "Awesome!";
                                    this.m_coin_success_tf.text = orderXML["@dimes"];
                                    this.m_coinsGrantQty_tf.text = "+";
                                    this.m_coinsGrantQty_tf.visible = true;
                                    this.m_coinsIconImg_mc.visible = true;
                                    this.m_coin_success_tf.visible = true;
                                    this.m_success_tf.text = "You have successfully\ncooked " + stationData["cookedOrder"].toString();
                                    this.m_success_tf.visible = true;
                                    this.m_success_icon_mc.loadIcon(orderXML["@iconurl"]);
                                    this.m_success_icon_mc.visible = true;
                                 }
                                 else
                                 {
                                    this.m_exclamation_mc.visible = false;
                                    this.m_failSubtext_tf.text = "You need to start over\nand try another recipe!";
                                    this.m_failSubtext_tf.visible = true;
                                    this.m_station_bt.text = "Start Over";
                                    this.m_fail_tf.text = "Cooked order is not available";
                                    this.m_fail_tf.visible = true;
                                 }
                                 this.m_ingredientFrame.visible = false;
                                 this.m_stationSubtext_tf.visible = false;
                                 this.m_stationName_tf.visible = false;
                              }
                           }
                           else
                           {
                              this.m_ingredientFrame.refresh();
                           }
                           this.m_cookedOrder = stationData["cookedOrder"];
                        }
                        else
                        {
                           this.m_ingredientFrame.refresh();
                        }
                     }
                  }
               }
               if(!isRedeem)
               {
                  this.manager.mainWindow.refreshStationOrderAndIngredientFrames();
               }
            }
            else if(data.hasOwnProperty("StationData"))
            {
               if(Boolean(stationData) && stationData.hasOwnProperty("state"))
               {
                  if(stationData["state"] == CocowonderlandInnovationManager.STATION_STATES[CocowonderlandInnovationManager.STATION_STATE_LOCKED])
                  {
                     if(this.m_slotNumber == 1)
                     {
                        this.m_stationSubtext_tf.text = "Reach Sous Chef level to unlock this station for today.";
                        this.m_stationLock_mc.loadIcon(STATION_1_URL);
                     }
                     else if(this.m_slotNumber == 2)
                     {
                        this.m_stationSubtext_tf.text = "Reach Patissier level to unlock this station for today.";
                        this.m_stationLock_mc.loadIcon(STATION_2_URL);
                     }
                     this.m_stationSubtext_tf.visible = true;
                     this.m_stationLock_mc.visible = true;
                     this.m_ingredientFrame.visible = false;
                  }
                  else
                  {
                     this.m_stationLock_mc.visible = false;
                     if(stationData.hasOwnProperty("cookTimeStart"))
                     {
                        this.m_cookTimeStart = stationData["cookTimeStart"];
                        ingredientCount = 0;
                        if(stationData.hasOwnProperty("ingredients"))
                        {
                           ingredientArray = [];
                           for each(ingredient in stationData["ingredients"])
                           {
                              ingredientXML = this.manager.getIngredientXML(ingredient);
                              if(ingredientXML)
                              {
                                 ingredientCount++;
                                 ingredientArray.push(ingredientXML);
                              }
                           }
                           this.m_ingredientFrame.setData(ingredientArray);
                        }
                        refreshIngredients = true;
                        if(this.m_cookTimeStart > 0)
                        {
                           this.m_cookingStarted = true;
                           if(this.manager.isCookDone(this.m_slotNumber))
                           {
                              this.m_station_bt.visible = true;
                              this.m_station_bt.text = "serve";
                              this.m_station_bt.callback = this.onServe;
                              refreshIngredients = false;
                              if(stationData.hasOwnProperty("cookedOrder"))
                              {
                                 orderXML1 = this.manager.getOrderXML(stationData["cookedOrder"]);
                                 if(stationData["cookedOrder"] != "")
                                 {
                                    this.m_station_bt.text = "Awesome!";
                                    this.m_coin_success_tf.text = orderXML1["@dimes"];
                                    this.m_coinsGrantQty_tf.text = "+";
                                    this.m_coinsGrantQty_tf.visible = true;
                                    this.m_coinsIconImg_mc.visible = true;
                                    this.m_coin_success_tf.visible = true;
                                    this.m_success_tf.text = "You have successfully\ncooked " + stationData["cookedOrder"].toString();
                                    this.m_success_tf.visible = true;
                                    this.m_success_icon_mc.loadIcon(orderXML1["@iconurl"]);
                                    this.m_success_icon_mc.visible = true;
                                 }
                                 else
                                 {
                                    this.m_failSubtext_tf.text = "Add correct ingredients\nand cook again!";
                                    this.m_failSubtext_tf.visible = true;
                                    this.m_station_bt.text = "Start Over";
                                    this.m_fail_tf.text = "Wrong Recipe!";
                                    this.m_fail_tf.visible = true;
                                 }
                                 this.m_ingredientFrame.visible = false;
                                 this.m_stationSubtext_tf.visible = false;
                                 this.m_stationName_tf.visible = false;
                              }
                           }
                           else
                           {
                              this.startTimer();
                           }
                           this.m_cookedOrder = stationData["cookedOrder"];
                        }
                        else
                        {
                           this.m_station_bt.visible = true;
                           this.m_station_bt.text = "Cook";
                           this.m_station_bt.enabled = ingredientCount > 0;
                           if(this.m_station_bt.enabled)
                           {
                              this.m_station_bt.callback = this.onCook;
                           }
                           else
                           {
                              this.m_station_bt.callback = null;
                           }
                           if(data.hasOwnProperty("highlight") && data["highlight"].toString() == true.toString())
                           {
                              this.m_stationHighlight_mc.visible = true;
                              this.m_stationSubtext_tf.text = "You are currently adding\ningredients to this station.";
                              this.m_stationSubtext_tf.visible = true;
                              this.m_ingredientFrame.visible = false;
                           }
                           else
                           {
                              this.m_stationSubtext_tf.text = "This station is unlocked!\nIt is available for cooking.";
                              this.m_stationSubtext_tf.visible = true;
                              this.m_ingredientFrame.visible = false;
                           }
                        }
                        if(refreshIngredients)
                        {
                           this.m_ingredientFrame.refresh();
                        }
                     }
                  }
               }
            }
         }
         if(this.m_station_bt.enabled)
         {
            this.m_station_bt.detachTooltip();
         }
         else
         {
            this.m_station_bt.element.mouseEnabled = this.m_station_bt.element.mouseChildren = true;
            this.m_station_bt.attachTooltip(new FarmTextTooltip("Add Ingredients."));
         }
      }
      
      private function startTimer() : void
      {
         this.m_cookTimer = new Timer(1000);
         this.m_cookTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_cookTimer.start();
         this.showProgressBar();
         this.updateProgressBar();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.updateProgressBar();
      }
      
      private function showProgressBar() : void
      {
         if(this.m_cook_progress_mc)
         {
            this.m_cook_progress_mc.visible = true;
         }
         if(this.m_progress_text_tf)
         {
            this.m_progress_text_tf.visible = true;
         }
         if(this.m_progress_fill_mc)
         {
            this.m_progress_fill_mc.visible = true;
            TweenMax.to(this.m_progress_fill_mc,0,{"x":int(-BAR_LENGTH)});
         }
      }
      
      private function hideProgressBar() : void
      {
         if(this.m_cook_progress_mc)
         {
            this.m_cook_progress_mc.visible = false;
         }
         if(this.m_progress_text_tf)
         {
            this.m_progress_text_tf.visible = false;
         }
         if(this.m_progress_fill_mc)
         {
            this.m_progress_fill_mc.visible = false;
         }
      }
      
      public function getFormattedTimeLeft(timeLeft:Number) : String
      {
         var minutes:int = 0;
         var seconds:int = 0;
         var resultMin:String = "";
         var resultSec:String = "";
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
            return "00:00";
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            minutes = int(timeLeftArray[2]);
            seconds = int(timeLeftArray[3]);
            resultMin = "0" + minutes.toString();
            if(seconds < 10)
            {
               resultSec = "0" + seconds.toString();
            }
            else
            {
               resultSec = seconds.toString();
            }
         }
         return resultMin + ":" + resultSec;
      }
      
      private function updateProgressBar() : void
      {
         var orderXML:XML = null;
         var fill:* = undefined;
         var now:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var cookTime:int = this.manager.getCookTime();
         var endTime:int = this.m_cookTimeStart + cookTime;
         var timeLeft:int = endTime - now;
         var timeText:String = this.getFormattedTimeLeft(timeLeft);
         this.m_progress_text_tf.text = "Ready in " + timeText;
         var weekData:Object = this.manager.getCurrentWeek();
         var curWeek:int = weekData.count - 1;
         if(now - this.m_cookTimeStart >= cookTime)
         {
            this.removeTimer();
            if(Boolean(this.m_StationAnimationMC_Array) && Boolean(this.m_StationAnimationMC_Array[curWeek]))
            {
               this.m_StationAnimationMC_Array[curWeek].gotoAndStop(this.STATION_ANIMATION_FRAME_ARRAY[curWeek] - 1);
            }
            this.hideProgressBar();
            this.m_station_bt.visible = true;
            this.m_station_bt.callback = this.onServe;
            orderXML = this.manager.getOrderXML(this.m_cookedOrder);
            if(Boolean(this.m_cookedOrder) && this.m_cookedOrder != "")
            {
               this.m_station_bt.text = "Awesome!";
               this.m_coin_success_tf.text = orderXML["@dimes"];
               this.m_coinsGrantQty_tf.visible = true;
               this.m_coinsIconImg_mc.visible = true;
               this.m_coinsGrantQty_tf.text = "+";
               this.m_coin_success_tf.visible = true;
               this.m_success_tf.text = "You have sucessfully cooked " + this.m_cookedOrder;
               this.m_success_tf.visible = true;
               this.m_success_icon_mc.loadIcon(orderXML["@iconurl"]);
               this.m_success_icon_mc.visible = true;
               this.m_success_icon_mc.setIconSize(100,100);
            }
            else
            {
               this.m_failSubtext_tf.text = "Add correct ingredients\nand cook again!";
               this.m_failSubtext_tf.visible = true;
               this.m_station_bt.text = "Start Over";
               this.m_fail_tf.text = "Wrong Recipe!";
               this.m_fail_tf.visible = true;
            }
            this.m_stationSubtext_tf.visible = false;
            this.m_ingredientFrame.visible = false;
            this.m_stationName_tf.visible = false;
         }
         else
         {
            if(Boolean(this.m_StationAnimationMC_Array) && Boolean(this.m_StationAnimationMC_Array[curWeek]))
            {
               this.m_StationAnimationMC_Array[curWeek].gotoAndPlay(this.STATION_ANIMATION_FRAME_ARRAY[curWeek]);
            }
            fill = (now - this.m_cookTimeStart) / cookTime * BAR_LENGTH;
            if(int(fill) != int(this.m_lastFill))
            {
               this.m_lastFill = fill;
               TweenMax.to(this.m_progress_fill_mc,0.1,{"x":int(fill - BAR_LENGTH)});
            }
         }
      }
      
      private function onServe(event:Event) : void
      {
         this.m_station_bt.visible = false;
         this.manager.onServe(this.m_slotNumber,this.m_cookedOrder);
         this.m_coinsIconImg_mc.visible = false;
         this.m_coinsGrantQty_tf.visible = false;
         this.m_cookingStarted = false;
         this.m_coin_success_tf.visible = false;
      }
      
      private function onComplete(event:Event) : void
      {
         this.m_station_bt.visible = false;
         this.manager.onComplete(this.m_slotNumber);
      }
      
      private function onCook(event:Event) : void
      {
         this.m_station_bt.visible = false;
         this.m_stationHighlight_mc.visible = false;
         var ingredientArray:Array = this.m_ingredientFrame.getIngredients();
         this.manager.startCooking(this.m_slotNumber,ingredientArray);
         this.m_cookingStarted = true;
         this.m_stationName_tf.visible = true;
      }
      
      private function get manager() : CocowonderlandInnovationManager
      {
         return CocowonderlandInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function isCookingStarted() : Boolean
      {
         return this.m_cookingStarted;
      }
      
      public function checkAndAddIngredient(ingredient:XML) : Boolean
      {
         var result:Boolean = false;
         if(this.m_cookingStarted)
         {
            return false;
         }
         result = this.m_ingredientFrame.checkAndAddIngredient(ingredient);
         if(result)
         {
            this.m_stationSubtext_tf.visible = false;
            this.m_ingredientFrame.visible = true;
            this.m_station_bt.enabled = true;
            this.m_station_bt.callback = this.onCook;
            this.m_station_bt.detachTooltip();
         }
         return result;
      }
      
      public function onStartCooking(cookedOrder:String, cookTimeStart:int) : void
      {
         this.m_cookedOrder = cookedOrder;
         this.m_ingredientFrame.onStartCooking();
         var weekData:Object = this.manager.getCurrentWeek();
         var curWeek:int = weekData.count - 1;
         if(this.manager.isCookingInProgress(this.m_slotNumber))
         {
            this.m_StationAnimationMC_Array[curWeek].gotoAndPlay(this.STATION_ANIMATION_FRAME_ARRAY[curWeek]);
         }
         else
         {
            this.m_StationAnimationMC_Array[curWeek].gotoAndStop(this.STATION_ANIMATION_FRAME_ARRAY[curWeek] - 1);
         }
         this.m_cookTimeStart = cookTimeStart;
         this.startTimer();
      }
      
      public function onRemoveIngredient(ingredientCount:int) : void
      {
         if(ingredientCount == 0)
         {
            this.m_station_bt.enabled = false;
            this.m_station_bt.callback = null;
            this.m_station_bt.element.mouseEnabled = this.m_station_bt.element.mouseChildren = true;
            this.m_station_bt.attachTooltip(new FarmTextTooltip("Add Ingredients."));
            if(this.m_stationHighlight_mc.visible)
            {
               this.m_stationSubtext_tf.text = "You are currently adding\ningredients to this station.";
               this.m_stationSubtext_tf.visible = true;
               this.m_ingredientFrame.visible = false;
            }
         }
      }
      
      public function removeTimer() : void
      {
         if(this.m_cookTimer)
         {
            this.m_cookTimer.stop();
            this.m_cookTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_cookTimer = null;
         }
      }
      
      public function hideStation(hide:Boolean) : void
      {
         var weekData:Object = this.manager.getCurrentWeek();
         var curWeek:int = weekData.count - 1;
         if(Boolean(this.m_StationAnimationMC_Array) && Boolean(this.m_StationAnimationMC_Array[curWeek]))
         {
            if(hide)
            {
               this.m_StationAnimationMC_Array[curWeek].visible = false;
            }
            else
            {
               this.m_StationAnimationMC_Array[curWeek].visible = true;
               if(this.manager.isStationLocked(this.m_slotNumber))
               {
                  if(curWeek == 5)
                  {
                     this.m_iconStation5_grey_mc.visible = true;
                  }
                  else
                  {
                     this.m_StationAnimationMC_Array[curWeek].gotoAndStop(this.STATION_DISABLED_FRAME_ARRAY[curWeek]);
                     this.m_iconStation5_grey_mc.visible = false;
                  }
               }
               else
               {
                  this.m_StationAnimationMC_Array[curWeek].gotoAndPlay(this.STATION_ANIMATION_FRAME_ARRAY[curWeek]);
               }
            }
         }
      }
   }
}

