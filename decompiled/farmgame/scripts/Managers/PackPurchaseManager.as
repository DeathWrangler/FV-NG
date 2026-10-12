package Managers
{
   import Widgets.Windows.PackPurchasedToaster;
   import flash.utils.Dictionary;
   
   public class PackPurchaseManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_currentPackId:String = "";
      
      private static var m_instance:PackPurchaseManager = null;
      
      private var m_purchases:Dictionary = new Dictionary();
      
      private var m_showPackToaster:Boolean = false;
      
      public function PackPurchaseManager()
      {
         super();
         if(!m_initialized)
         {
            m_currentPackId = "";
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use PackPurchaseManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : PackPurchaseManager
      {
         if(m_instance == null)
         {
            m_instance = new PackPurchaseManager();
         }
         return m_instance;
      }
      
      public static function onInGamePackPaymentEnd(packageCode:String) : void
      {
         if(packageCode != "" && packageCode != null && packageCode != "undefined")
         {
            PackPurchaseManager.getInstance().trackPackPurchase();
            PackPurchaseManager.getInstance().setToasterFlag();
         }
      }
      
      public function addPackPurchase(packId:String, purchaseCount:Number) : void
      {
         this.m_purchases[packId] = purchaseCount;
      }
      
      public function trackPackPurchase(packId:String = "") : void
      {
         if(packId == "" && m_currentPackId != "")
         {
            packId = m_currentPackId;
         }
         this.m_purchases[packId] = this.getNumberOfPackPurchases(packId) + 1;
         FarmStatsManager.count("payment","in_app","starter_pack","in_game");
      }
      
      public function trackPack(packId:String = "") : void
      {
         m_currentPackId = packId;
      }
      
      public function getNumberOfPackPurchases(packId:String) : Number
      {
         var purchaseCount:Number = 0;
         if(this.m_purchases[packId])
         {
            purchaseCount = Number(this.m_purchases[packId]);
         }
         return purchaseCount;
      }
      
      public function shouldShowPackPurchasesToaster() : Boolean
      {
         return this.m_showPackToaster;
      }
      
      public function setToasterFlag() : void
      {
         this.m_showPackToaster = true;
      }
      
      public function showPackPurchasesToaster() : void
      {
         if(this.m_showPackToaster)
         {
            ToasterManager.getInstance().add(new PackPurchasedToaster());
            this.m_showPackToaster = false;
         }
      }
   }
}

