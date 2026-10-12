package Managers
{
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshGifts;
   import Widgets.SameFeatureFriendsWindow;
   import Widgets.Windows.MFSAddNeighbor;
   
   public class SameFeatureFriendsManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "sameFeatureFriends";
      
      private const ASSET_MAIN:String = "main";
      
      private const SERVICE_NAME:String = "SameFeatureFriendsService";
      
      private const API_ERROR_NEIGHBORS_LIMIT_REACHED:String = "neighborsLimitReached";
      
      public var m_window:SameFeatureFriendsWindow = null;
      
      public var isLoading:Boolean = false;
      
      public var m_neighborSuggestions:Object;
      
      private var m_canOpenUI:Boolean = true;
      
      public function SameFeatureFriendsManager(featureName:String)
      {
         super(featureName);
      }
      
      public static function get instance() : SameFeatureFriendsManager
      {
         var instance:SameFeatureFriendsManager = BaseFeatureManager.getInstanceOfClass(FEATURE_NAME,SameFeatureFriendsManager) as SameFeatureFriendsManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function showMainUI() : void
      {
         if(this.m_canOpenUI)
         {
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"getNeighborSuggestions",this.onGetNeigborSuggestions,[m_featureName]));
            this.isLoading = true;
            this.m_canOpenUI = false;
            FarmStatsManager.count("samefeaturefriends","main_ui","view");
            UI.displayPopup(this.m_window = new SameFeatureFriendsWindow(super.getAssetURL(this.ASSET_MAIN),FEATURE_NAME));
         }
      }
      
      public function openNeighbors() : void
      {
         UI.displayPopup(new MFSAddNeighbor(this.m_featureName,null));
         this.m_window.close();
      }
      
      public function sendNeighborRequest(uid:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"sendNeighborRequest",this.onSendNeighborRequest,[m_featureName,uid]));
         WanderingPirateManager.getInstance().changeCurrencyCount();
      }
      
      private function onSendNeighborRequest(res:Object) : void
      {
         TransactionManager.addTransaction(new TRefreshGifts());
      }
      
      private function onGetNeigborSuggestions(res:Object) : void
      {
         this.isLoading = false;
         if(res[this.API_ERROR_NEIGHBORS_LIMIT_REACHED])
         {
            this.m_window.showCleanNeighbors();
            this.m_window.hideLoader();
            FarmStatsManager.count("samefeaturefriends","main_ui","full_list");
            return;
         }
         this.m_neighborSuggestions = res;
         if(this.m_window)
         {
            this.m_window.initSuggestionSlots(res);
            this.m_window.hideLoader();
         }
      }
      
      public function set canOpenUI(res:Boolean) : void
      {
         this.m_canOpenUI = res;
      }
   }
}

