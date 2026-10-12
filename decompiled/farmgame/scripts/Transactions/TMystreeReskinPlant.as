package Transactions
{
   import Classes.MystreeReskinSapling;
   
   public class TMystreeReskinPlant extends TPlant
   {
      
      private var m_callback:Function;
      
      private var m_featueName:String;
      
      public function TMystreeReskinPlant(resource:MystreeReskinSapling, featureName:String, isGift:Boolean = false, energySource:int = 0, energy:Number = 0, energyMetadata:Object = null, containerId:Number = 0, currency:String = "", callback:Function = null)
      {
         var mystreeSapling:MystreeReskinSapling = null;
         super(resource,isGift,energySource,energy,energyMetadata,containerId,currency);
         if(resource is MystreeReskinSapling)
         {
            mystreeSapling = resource as MystreeReskinSapling;
            m_params.plotId = mystreeSapling.m_plotId;
         }
         this.m_callback = callback;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}

