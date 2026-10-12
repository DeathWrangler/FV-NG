package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   
   public class CharityManager
   {
      
      private var m_Object:Object;
      
      private const DR_ASSET_PATH:String = "assets/dialogs/Logos_DirectRelief.png";
      
      private const FH_ASSET_PATH:String = "assets/dialogs/Logos_FisherHouse.png";
      
      private const IAVA_ASSET_PATH:String = "assets/dialogs/Logos_IAVA.png";
      
      private const WFP_ASSET_PATH:String = "assets/dialogs/Logos_WFP.png";
      
      public function CharityManager()
      {
         super();
      }
      
      public function setCharity(charity:Object) : void
      {
         this.m_Object = charity;
      }
      
      public function get motdTitle() : String
      {
         var motdTitle:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("motdtitle"))
         {
            motdTitle = this.m_Object.motdtitle;
         }
         return motdTitle;
      }
      
      public function get motdBody() : String
      {
         var motdBody:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("motdbody"))
         {
            motdBody = this.m_Object.motdbody;
         }
         return motdBody;
      }
      
      public function get npc() : String
      {
         var npc:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("npc"))
         {
            npc = this.m_Object.npc;
         }
         return npc;
      }
      
      public function get logoUrl() : String
      {
         var logo:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("logo"))
         {
            logo = this.m_Object.logo;
            switch(logo)
            {
               case "directrelief":
                  return Global.getAssetURL(this.DR_ASSET_PATH);
               case "fisherhouse":
                  return Global.getAssetURL(this.FH_ASSET_PATH);
               case "iava":
                  return Global.getAssetURL(this.IAVA_ASSET_PATH);
               case "wfp":
                  return Global.getAssetURL(this.WFP_ASSET_PATH);
            }
         }
         return "";
      }
      
      public function get item() : String
      {
         var item:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("item"))
         {
            item = this.m_Object.item;
         }
         return item;
      }
      
      public function get url() : String
      {
         var url:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("url"))
         {
            url = this.m_Object.url;
         }
         return url;
      }
      
      public function get urlText() : String
      {
         var urlTxt:String = "";
         if(Boolean(this.m_Object) && this.m_Object.hasOwnProperty("urlTxt"))
         {
            urlTxt = this.m_Object.urlTxt;
         }
         return urlTxt;
      }
      
      public function isActive() : Boolean
      {
         var isActive:Boolean = false;
         if(this.m_Object)
         {
            isActive = true;
         }
         return this.inExperiment() && isActive;
      }
      
      public function inExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GENERIC_CHARITY) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
      
      public function getCharityItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByName(this.item);
      }
   }
}

