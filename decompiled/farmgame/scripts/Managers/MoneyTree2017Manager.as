package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Widgets.Windows.MoneyTree2017ToasterWindow;
   import Widgets.Windows.MoneyTree2017Window;
   import Widgets.Windows.MoneyTreeCongratsWindow;
   import flash.events.Event;
   
   public class MoneyTree2017Manager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "Money_Tree_2020";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUYDIALOG_CONFIRMATION:String = "buyConfirmation";
      
      private static const KEY_GOLDEN_TREE_COUNT:String = "g";
      
      private static const KEY_CRYSTALLINE_TREE_COUNT:String = "c";
      
      private static const MAX_PURCHSE_LIMIT:int = 4;
      
      private static const WINDOW_TOASTER:String = "toaster";
      
      private static const PAYMENT_CODE_MAP:Object = {
         "silverbillsprosperytree":"7:846166127",
         "goldbillsprosperytree":"7:846165554"
      };
      
      private static const PAYMENT_CODE_MAP1:Object = {
         "silverbillsprosperytree":"2oxo",
         "goldbillsprosperytree":"2ov2"
      };
      
      private static const TOASTER_TIMEOUT:int = 20000;
      
      private static var m_initialized:Boolean = false;
      
      private var m_assetPaths:Object = null;
      
      private var m_mainWindow:MoneyTree2017Window;
      
      private var m_activeItemName:String = "";
      
      private var m_moneyTreeToaster:MoneyTree2017ToasterWindow;
      
      protected var m_staticData:Object;
      
      public function MoneyTree2017Manager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "Money_Tree_2020") : MoneyTree2017Manager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,MoneyTree2017Manager) as MoneyTree2017Manager;
      }
      
      public function showMainUI() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         else
         {
            UI.displayPopup(this.m_mainWindow = new MoneyTree2017Window(m_featureName,this.mainWindowURL));
            FarmStatsManager.count("Prosperytree","main_ui","open_window","impression");
         }
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[KEY_GOLDEN_TREE_COUNT] = 0;
            featureData[KEY_CRYSTALLINE_TREE_COUNT] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,m_featureName,featureData);
         }
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var asset:XML = null;
         this.m_staticData = {};
         this.m_staticData.items = [];
         this.m_staticData.costArray = [];
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = {};
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            for each(itemXML in featureXML.items.item)
            {
               this.m_staticData.items.push(itemXML.@name.toString());
               this.m_staticData.costArray.push(itemXML.@cost.toString());
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get buyConfirmationURL() : String
      {
         return this.m_assetPaths[WINDOW_BUYDIALOG_CONFIRMATION];
      }
      
      public function get buyCongratsURL() : String
      {
         return this.m_assetPaths[WINDOW_CONGRATS];
      }
      
      public function get toasterDialog() : String
      {
         return this.m_assetPaths[WINDOW_TOASTER];
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTimeText:String = null;
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var requirement:Object = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("money_tree_2020");
         var requirementsArray:Array = prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         for each(requirement in requirementsArray)
         {
            if(requirement.type == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               endTimeText = requirement.value;
               break;
            }
         }
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(endTimeText);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      public function get mainWindow() : MoneyTree2017Window
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(mainWindow:MoneyTree2017Window) : void
      {
         this.m_mainWindow = mainWindow;
      }
      
      public function buyTree(itemName:String) : void
      {
         this.m_activeItemName = itemName;
         if(Global.eosManager.getEosVariant("fv_prosperytree_2020") == 2)
         {
            PaymentUtil.instance.addPaymentItemToCart(PAYMENT_CODE_MAP[itemName],1,m_featureName,this.onPaymentSuccess,this.onPaymentFailure);
            FarmStatsManager.count("Prosperytree","purchase",this.m_activeItemName,"purchase_initiated");
         }
      }
      
      private function onPaymentSuccess(orderId:String = "", status:String = "") : void
      {
         var reachedTreeLimit:Boolean = false;
         var featureDef:FeatureMessagingDefinition = null;
         var farmData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(this.m_activeItemName == "silverbillsprosperytree")
         {
            farmData[KEY_GOLDEN_TREE_COUNT] += 1;
         }
         else if(this.m_activeItemName == "goldbillsprosperytree")
         {
            farmData[KEY_CRYSTALLINE_TREE_COUNT] += 1;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,farmData);
         Global.player.addGift(this.m_activeItemName,"0",1);
         UI.refreshGiftBoxWindow();
         var numOfTreesBought:int = (farmData[KEY_GOLDEN_TREE_COUNT] as int) + (farmData[KEY_CRYSTALLINE_TREE_COUNT] as int);
         if(numOfTreesBought == MAX_PURCHSE_LIMIT)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,"limit",1);
            reachedTreeLimit = true;
            this.showCongratulationsWindow(reachedTreeLimit);
            FarmStatsManager.count("Prosperytree","purchase_congrats","open",this.m_activeItemName,"last_purchase");
            featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(FEATURE_NAME);
            if(featureDef)
            {
               featureDef.updateIconVisibility();
            }
         }
         else
         {
            this.showCongratulationsWindow();
            FarmStatsManager.count("Prosperytree","purchase_congrats","open",this.m_activeItemName);
         }
         this.m_activeItemName = "";
      }
      
      private function onPaymentFailure(orderId:String = "", status:String = "") : void
      {
         FarmStatsManager.count("Prosperytree","purchase",this.m_activeItemName,"purchase_failed");
         this.m_activeItemName = "";
         UI.showMessage("Payment failed. Please try again.");
         this.mainWindow.untintWindow();
         this.mainWindow.enableInput = true;
      }
      
      public function showCongratulationsWindow(reachedLimit:Boolean = false) : void
      {
         var congratsWindow:MoneyTreeCongratsWindow = new MoneyTreeCongratsWindow(m_featureName,this.buyConfirmationURL,this.m_activeItemName,reachedLimit);
         UI.displayPopup(congratsWindow,false);
      }
      
      public function showConditionalToaster() : void
      {
         var seenFlag:String = null;
         var goldenTreeCount:int = 0;
         var crystallineTreeCount:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(Boolean(featureData) && featureData.hasOwnProperty(KEY_GOLDEN_TREE_COUNT))
         {
            goldenTreeCount = int(featureData[KEY_GOLDEN_TREE_COUNT]);
         }
         if(Boolean(featureData) && featureData.hasOwnProperty(KEY_CRYSTALLINE_TREE_COUNT))
         {
            crystallineTreeCount = int(featureData[KEY_CRYSTALLINE_TREE_COUNT]);
         }
         if(goldenTreeCount > 0 || crystallineTreeCount > 0)
         {
            seenFlag = "MoneyTree2020Toaster" + FarmGameUtil.getMidnightTimestamp().toString();
            ToasterManager.getInstance().togglePauseQueue(false);
            ToasterManager.getInstance().addImmediate(this.m_moneyTreeToaster = new MoneyTree2017ToasterWindow("assets/dialogs/MoneyTree_2020/FV_MoneyTree_2020_toaster.swf",ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_toasterTitle"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_toasterBody",{"time":HUD.getformattedTimeLeft(this.getTimeLeftInDay())}),"Okay!",this.hidMoneyTreeToaster,TOASTER_TIMEOUT));
            Global.player.setSeenFlag(seenFlag);
            FarmStatsManager.count("Prosperytree","toaster","impression");
         }
      }
      
      public function hidMoneyTreeToaster(e:Event = null) : void
      {
         this.m_moneyTreeToaster.close();
         FarmStatsManager.count("Prosperytree","toaster","close");
      }
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
   }
}

