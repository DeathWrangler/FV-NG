package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCResourceDelegate;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   
   public class FeaturedRenderFUGCObject extends FeaturedRenderFObject implements IUGCMapResource
   {
      
      private var m_ugcDelegate:UGCResourceDelegate = null;
      
      private var m_ugcUuid:String = null;
      
      public function FeaturedRenderFUGCObject(itemName:String, building:FeatureBuilding, metadata:String = "")
      {
         super(itemName,building,metadata);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(farmItem)
         {
            if(farmItem is IUGCItem)
            {
               this.m_ugcUuid = metadata as String;
               this.m_ugcDelegate = new UGCResourceDelegate(this,this.m_ugcUuid);
               this.m_ugcDelegate.refresh();
            }
         }
      }
      
      override protected function initializeFilters() : void
      {
         super.initializeFilters();
         if(this.m_ugcDelegate != null)
         {
            this.m_ugcDelegate.initializeFilters(m_content);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var result:String = null;
         if(this.m_ugcDelegate != null)
         {
            result = this.m_ugcDelegate.getCurrentImageName();
         }
         else
         {
            result = super.getCurrentImageName();
         }
         return result;
      }
      
      public function get ugcDelegate() : UGCResourceDelegate
      {
         return this.m_ugcDelegate;
      }
      
      public function get ugcUuid() : String
      {
         return this.m_ugcUuid;
      }
      
      public function get isCustomizable() : Boolean
      {
         return false;
      }
      
      public function set ugcUuid(value:String) : void
      {
         if(this.m_ugcUuid != value)
         {
            this.m_ugcUuid = value;
            if(this.m_ugcDelegate == null)
            {
               this.m_ugcDelegate = new UGCResourceDelegate(this,this.m_ugcUuid);
            }
            else
            {
               this.m_ugcDelegate.loadUGCItemState(this.m_ugcUuid);
            }
            this.m_ugcDelegate.refresh();
         }
      }
   }
}

