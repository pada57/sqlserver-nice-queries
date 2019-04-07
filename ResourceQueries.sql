/*
DELETE FROM dbo.aspnet_Profile
SELECT * from dbo.aspnet_Profile
exec dbo.aspnet_Profile_SetProperties @ApplicationName=N'RCP',@UserName=N'admin',@PropertyNames=N'UserLanguage:S:0:2:PreferedUICulture:S:2:0:',@PropertyValuesString=N'en',@PropertyValuesBinary=0x,@IsUserAnonymous=0,@CurrentTimeUtc='2014-05-05 12:01:29.657'
exec dbo.aspnet_Profile_GetProperties @ApplicationName=N'RCP',@UserName=N'admin',@CurrentTimeUtc='2014-05-05 12:01:29.707'
*/
EXEC dbo.aspnet_local_resources_generate
EXEC dbo.aspnet_global_resources_generate

SELECT * FROM aspnet_virtual_paths  order BY 2 desc
SELECT * FROM aspnet_virtual_paths where VirtualPath='~/Site/Pages/Parameterization/Details/AgreementDetails.aspx'
SELECT * FROM aspnet_virtual_paths where VirtualPath LIKE '%GridFeeRates%'

SELECT * FROM dbo.aspnet_class_names
SELECT * FROM dbo.aspnet_global_resources
SELECT * FROM dbo.aspnet_local_resources
select * FROM dbo.aspnet_local_resources where ResourceValue LIKE '%effectuer une opération demandée alors que sont en attente de changements pour la définition de versio%'

-- Local resources
SELECT VP.VirtualPath
      ,LR.ResourceKey
      ,LR.CultureCode
      ,LR.ResourceValue
FROM dbo.aspnet_local_resources AS LR
INNER JOIN dbo.aspnet_virtual_paths AS VP
        ON LR.VirtualPathId = VP.VirtualPathId
WHERE VP.VirtualPath LIKE '~/Site/UserControls/GridFeeRates.ascx'
  --AND LR.ResourceKey like '%imgIsAmountAmended%'
ORDER BY VP.VirtualPath, LR.ResourceKey, LR.CultureCode

UPDATE dbo.aspnet_local_resources SET ResourceValue = 'Add to List' WHERE ResourceKey = 'btnAddList.Value' and VirtualPathId='1514940D-76F6-46DE-ADF9-C42D8636547C' AND CultureCode <> 'fr-FR'
UPDATE dbo.aspnet_local_resources SET ResourceValue = 'Synchronisation de Active Directory' WHERE ResourceKey = 'label1.Text' and VirtualPathId='E3A93139-E6A3-46A9-B36F-F83B178F30C8' AND CultureCode = 'fr-FR'


-- Global resources
SELECT ACN.ClassName
    , GR.ResourceKey
    , GR.CultureCode
    , GR.ResourceValue
    , GR.ResourceId
FROM dbo.aspnet_global_resources AS GR
INNER JOIN dbo.aspnet_class_names ACN
    ON GR.ClassNameId = ACN.ClassNameId
WHERE ACN.ClassName LIKE '%Sitemap%'
ORDER BY ACN.ClassName, GR.ResourceKey
    

UPDATE dbo.aspnet_global_resources
SET ResourceValue = 'Contrôle des paiements'
WHERE ResourceId = '925B54C5-0ABA-4CFF-A06A-2995D182386A'

SELECT * FROM dbo.aspnet_global_resources where ResourceValue LIKE 'Contrôle des pai%'
  
    
-- Insert missing resources for others languages
exec dbo.aspnet_resources_insertmissing

-- Init value entries with default culture (en)
; WITH ValueResources AS
(
    SELECT LR.VirtualPathId
          ,LR.ResourceKey
          ,LR.ResourceValue 
    FROM dbo.aspnet_local_resources AS LR
    WHERE LR.ResourceKey LIKE '%.Value'
      AND LR.CultureCode IS NULL
)
UPDATE LR
   SET ResourceValue = VR.ResourceValue
FROM dbo.aspnet_local_resources AS LR
INNER JOIN ValueResources       AS VR
        ON LR.VirtualPathId = VR.VirtualPathId
       AND LR.ResourceKey   = VR.ResourceKey
WHERE LR.CultureCode IS NOT NULL
  AND LR.ResourceValue <> VR.ResourceValue

    
insert INTO dbo.aspnet_virtual_paths(VirtualPathId, VirtualPath)
values(NEWID(),'~/Site/UserControls/DynamicUIControl.ascx')

insert INTO dbo.aspnet_virtual_paths(VirtualPathId, VirtualPath)
values(NEWID(),'~/Site/UserControls/GridFeeRates.ascx')

SELECT * from dbo.aspnet_class_names
select * FROM dbo.aspnet_global_resources where ClassNameId = '45FEC3DA-DB07-4CB9-8E05-FD2D3B668225'

SELECT * from dbo.aspnet_global_resources where ResourceValue like '%exceptions%'
SELECT * from aspnet_local_resources where ResourceValue like '%exceptions%'
SELECT * FROM dbo.aspnet_local_resources where ResourceId = '07A56952-90FA-4540-8B45-395A955520F7'

delete FROM dbo.aspnet_local_resources WHERE VirtualPathId = '93AF5C82-5E46-43AC-80F9-89D45647CD02'

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue) VALUES
('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', NULL, 'btnValidateSelectedOnClientClientMessage', 'Only those selected payments that have status Draft will be validated!')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', 'fr-FR', 'btnValidateSelectedOnClientClientMessage', 'Seulement les paiements sélectionnés avec un statut Brouillon seront validés!')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', NULL, 'btnAuthorizeSelectedOnClientClientMessage', 'Only those selected payments that have status Validated will be authorised!')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', 'fr-FR', 'btnAuthorizeSelectedOnClientClientMessage', 'Seulement les paiements sélectionnés avec un statut Valider seront autorisés!')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', NULL, 'btnForceAuthorizeSelectionOnClientClientMessage', 'Only those selected payments that have status Validated will be force authorised!')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', 'fr-FR', 'btnForceAuthorizeSelectionOnClientClientMessage', 'Seulement les paiements sélectionnés avec un statut Valider seront forcés à autoriser')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue) VALUES
('74CB3797-8A9C-4D9E-9378-15374283EDF6', NULL, 'rfvReference.ErrorMessage', 'Portfolio External Reference is required')
,('74CB3797-8A9C-4D9E-9378-15374283EDF6', 'fr-FR', 'rfvReference.ErrorMessage', 'Référence Externe est obligatoire')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue) VALUES
('BE93A078-DE4A-4205-B5A6-C0A5A0262B95', NULL, 'lblCounterpartyResource.Text', 'Counterparty Accounting Reference:')
,('BE93A078-DE4A-4205-B5A6-C0A5A0262B95', 'fr-FR', 'lblCounterpartyResource.Text', 'Référence Comptable de la Contrepartie:')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue) VALUES
('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'imageButton_update.AlternateText', 'Update')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'imageButton_cancel.AlternateText', 'Cancel')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'imageButton_edit.AlternateText', 'Edit')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'imageButton_delete.AlternateText', 'Delete')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'BoundFieldResource1.HeaderText', 'Product FeeID')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'TemplateFieldResource2.HeaderText', 'Date Start')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'TemplateFieldResource3.HeaderText', 'Date End')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'TemplateFieldResource4.HeaderText', '(%)')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'rfvFeeValueResource1.ToolTip', 'Please specify a Fee Value')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'btnAcceptResource1.Text', 'Accept')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'btnRejectResource1.Text', 'Reject')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'btnCancelResource1.Text', 'Cancel')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'TemplateFieldResource7.HeaderText', 'Priorities')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'label4Resource1.Text', 'Page size:')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'label_ErrMsgDuplicateFeeValue.Text', 'You cannot create/update/delete entries when the fee value does not change from one entry to another.')

-- Local resources

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue) VALUES
('38FD82AC-19D6-4336-8434-E90E228A8DA2', NULL, 'openFileErrorMessage', 'Could not open file')
,('38FD82AC-19D6-4336-8434-E90E228A8DA2', 'fr-FR', 'openFileErrorMessage', 'Le fichier ne peut pas être ouvert')
,('38FD82AC-19D6-4336-8434-E90E228A8DA2', NULL, 'fileEmptyErrorMessage', 'File is empty')
,('38FD82AC-19D6-4336-8434-E90E228A8DA2', 'fr-FR', 'fileEmptyErrorMessage', 'Le fichier est vide')
,('38FD82AC-19D6-4336-8434-E90E228A8DA2', NULL, 'fileStreamErrorMessage', 'Could not stream file content')
,('38FD82AC-19D6-4336-8434-E90E228A8DA2', 'fr-FR', 'fileStreamErrorMessage', 'Impossible de lire le contenu du fichier')

SELECT * FROM dbo.aspnet_local_resources where ResourceValue LIKE 'Reject'
SELECT * FROM dbo.aspnet_local_resources where VirtualPathId='93AF5C82-5E46-43AC-80F9-89D45647CD02' ORDER BY ResourceKey

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES 
('F6BB0967-012C-4933-B19D-CBA754EB4AD4', NULL, 'buttonAccept.Text', 'Accept')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'fr-FR', 'buttonAccept.Text', 'Accepter')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'de-DE', 'buttonAccept.Text', 'Accept')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', NULL, 'buttonReject.Text', 'Reject')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'fr-FR', 'buttonReject.Text', 'Rejeter')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'de-DE', 'buttonReject.Text', 'Reject')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', NULL, 'buttonCancel.Text', 'Cancel')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'fr-FR', 'buttonCancel.Text', 'Annuler')
,('F6BB0967-012C-4933-B19D-CBA754EB4AD4', 'de-DE', 'buttonCancel.Text', 'Cancel')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES 
('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', NULL, 'hopRebate.CheckBoxUseDefaultHOPText', 'Use Default HOP')
,('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', 'fr-FR', 'hopRebate.CheckBoxUseDefaultHOPText', 'Utiliser HOP par défaut')
,('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', NULL, 'hopThreshold.CheckBoxUseDefaultHOPText', 'Use same as rebate calculation')
,('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', 'fr-FR', 'hopThreshold.CheckBoxUseDefaultHOPText', 'Utiliser même que le calcul de remboursement')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES 
('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', NULL, 'imgIsPaymentCreatedManually.ToolTip', 'This payment has been created manually')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', 'fr-FR', 'imgIsPaymentCreatedManually.ToolTip', 'Ce paiement a été créé manuellement')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', NULL, 'isPaymentForcedToolTip', 'This payment has been forced')
,('16BA4C97-F8E4-4203-9F7B-3F2A9F2473FB', 'fr-FR', 'isPaymentForcedToolTip', 'Ce paiement a été forcé')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES 
('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'lblPercentageErrorMessage.Text', 'The percentage must be >= 0% and <= 100%.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', 'fr-FR', 'lblPercentageErrorMessage.Text', 'Le pourcentage doit être >= 0% et <= 100%.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'lblPercentageDecimalErrorMessage.Text', 'The percentage cannot have more than 6 decimal places.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', 'fr-FR', 'lblPercentageDecimalErrorMessage.Text', 'Le pourcentage ne doit pas avoir plus que 6 décimales.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'lblValueNotNumberErrorMessage.Text', 'This value is not valid. Please input a number.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', 'fr-FR', 'lblValueNotNumberErrorMessage.Text', 'La valeur n''est pas valide. Veuillez entrer un nombre.')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', NULL, 'lblDeleteConfirmationMessage.Text', 'Are you sure that you wish to delete this fee?')
,('93AF5C82-5E46-43AC-80F9-89D45647CD02', 'fr-FR', 'lblDeleteConfirmationMessage.Text', 'Êtes-vous sûr de vouloir supprimer ce frais ?')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E3A93139-E6A3-46A9-B36F-F83B178F30C8', NULL, 'lnkDescription.Text', 'Click the link below to synch <b>all</b> RCP Users with the settings (i.e. group memberships, display name) from the Active Directory.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E3A93139-E6A3-46A9-B36F-F83B178F30C8', 'fr-FR', 'lnkDescription.Text', 'Cliquer sur le lien ci-dessous afin de synchroniser <b>tous</b> les utilisateurs avec les paramètres (e.g. groupes, nom) de l''Active Directory')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('05B7FB33-2BF3-4635-9457-54D2E6F3E615', NULL, 'gridFeeRatesHistoryHeader', 'History of ')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('05B7FB33-2BF3-4635-9457-54D2E6F3E615', 'fr-FR', 'gridFeeRatesHistoryHeader', 'Historique de ')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('952AF6F1-CFB7-481C-A955-C0BD2E78E16E', NULL, 'redirectPortfolioMessage', 'The system will redirect to the portfolio list in order to search and select a portfolio to create a new certificate.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('952AF6F1-CFB7-481C-A955-C0BD2E78E16E', 'fr-FR', 'redirectPortfolioMessage', 'Vous allez être redirigé vers la liste des portefeuilles afin de rechercher et sélectionner un portefeuille pour créer le nouveau certificat.')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5F0F2067-601E-4246-BA90-63F44DA1F27D', NULL, 'searchCriterialTitle.Text', 'Search Criteria')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5F0F2067-601E-4246-BA90-63F44DA1F27D', 'fr-FR', 'searchCriterialTitle.Text', 'Critères de recherche')



INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', NULL, 'cbUseDefaultScale.Text', 'Use default scale')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', 'fr-FR', 'cbUseDefaultScale.Text', 'Utiliser le barème par défaut')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'savedSuccessMessage', 'Saved successfully!')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'savedSuccessMessage', 'Sauvegarde réussie.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'errorSavingMessage', 'Error during saving!')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'errorSavingMessage', 'Erreur de sauvegarde')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'errorDistributionCategoryExistsMessage', 'This distribution category already exists.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'errorDistributionCategoryExistsMessage', 'Cette catégorie de distribution existe déjà.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'errorDetailMessage', 'Error Details: ')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'errorDetailMessage', 'Details de l''erreur: ')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'innerExceptionMessage', 'Inner Exception: ')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'innerExceptionMessage', 'Exception interne: ')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'pageTitle', 'Distribution Category: {0}')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'pageTitle', 'Catégorie de distribution: {0}')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', NULL, 'newDistributionCategory', '(new Distribution Category)')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('670DA3D1-7E93-4933-AEDD-6EF06FE718BF', 'fr-FR', 'newDistributionCategory', '(nouvelle Catégorie de Distribution)')



INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('485A0E69-0D64-4064-892B-D41EE014A43D', NULL, 'creationSucceededMessage', 'Transfer saved successfully. Be aware that the certificate details may not be up to date immediately after this transfer.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('485A0E69-0D64-4064-892B-D41EE014A43D', 'fr-FR', 'creationSucceededMessage', 'Le transfert a été bien sauvegardé. Pour information, le détail du certificat pourrait ne pas être à jour immédiatement après ce transfert.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'contactDetailTitle.Text', 'Contact Details')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'contactDetailTitle.Text', 'Détails des contacts')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'ccSignDate.RequiredValidationMessage', 'Sign date is required.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'ccSignDate.RequiredValidationMessage', 'Date de signature est requise.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'ccCancelDate.RequiredValidationMessage', 'Cancellation date is required.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'ccCancelDate.RequiredValidationMessage', 'Date d''annulation est requise.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('58DBF251-88B3-4406-B851-30AA63B165E1', NULL, 'validationErrorMessage', 'This certificate cannot be validated due to existing differences or missing data.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('58DBF251-88B3-4406-B851-30AA63B165E1', 'fr-FR', 'validationErrorMessage', 'Ce certificat ne peut pas être validé à cause de différences existantes ou données manquantes.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('1E94C6D8-1332-4910-A4FF-E92D2CC57612', NULL, 'lblTitleAgreementList.Text', 'Agreements List')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('1E94C6D8-1332-4910-A4FF-E92D2CC57612', 'fr-FR', 'lblTitleAgreementList.Text', 'Liste des Conventions')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'IsNotValidForRebateContactCreation', 'All mandatory fields on the agreement details screen have to be filled prior to using the add button to enter rebate contact details.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'IsNotValidForRebateContactCreation', 'Tous les champs obligatoires sur le détail de convention doivent être renseignés avant d''utiliser le bouton ajouter pour entrer un contact de remboursement.')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'callSettNotValid', 'The system cannot save your changes because of missing data.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'callSettNotValid', 'Impossible de sauvegarder vos changements à cause de données manquantes.')
 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'successDeleted', 'Agreement successfully deleted')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'successDeleted', 'La convention a été supprimée avec succès')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'exceptionReason', ', for the following reason: ')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'exceptionReason', ', pour les raisons suivantes: ')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'noPendingChangesToSave', 'There are no pending changes to Save.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'noPendingChangesToSave', 'Aucun changement à sauvegarder')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5521BAB9-AD38-456C-885B-BD38A2B372B9', NULL, 'manageWindowCloseButtonMessage', 'If you have not clicked on the save button your changes will be lost.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5521BAB9-AD38-456C-885B-BD38A2B372B9', 'fr-FR', 'manageWindowCloseButtonMessage', 'Si vous ne cliquez pas sur le bouton sauvegarder vous perdrez vos changements.')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5521BAB9-AD38-456C-885B-BD38A2B372B9', NULL, 'controlPerformCheckAlertMessage', 'Are you sure you want to navigate away from this page?\n\nIf you have not clicked on the save button your changes can be lost.\n\nPress OK to continue, or Cancel to stay on the current page.')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5521BAB9-AD38-456C-885B-BD38A2B372B9', 'fr-FR', 'controlPerformCheckAlertMessage', 'Êtes-vous sûr de vouloir quitter cette page ?\n\nSi vous ne sauvegardez pas vos changements, ceux-ci seront perdus.\n\nCliquez OK pour continuer, ou Annuler pour rester sur la page.')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lblPaymentTitle.Text', 'Payments')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lblPaymentTitle.Text', 'Paiements')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lblReinvestmentTitle.Text', 'Reinvestments')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lblReinvestmentTitle.Text', 'Reinvestissements')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', NULL, 'cbUseDefaultEntityCalcSet.Text', 'Use default calculation parameters defined at Entity level')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', 'fr-FR', 'cbUseDefaultEntityCalcSet.Text', 'Utilisé les paramètres par défaut définis au niveau de l''entité')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('1514940D-76F6-46DE-ADF9-C42D8636547C', NULL, 'btnAddList.Value', 'Add to List')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('1514940D-76F6-46DE-ADF9-C42D8636547C', 'fr-FR', 'btnAddList.Value', 'Ajouter à la liste')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', NULL, 'lblRequiredField.Text', 'Required fields')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BBC74711-BE0E-46B8-9C2B-DF7281B77BF3', 'fr-FR', 'lblRequiredField.Text', 'Champs obligatoires')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', NULL, 'ytdFeeBaseAmount', 'YTD Fee Base Amount')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', 'fr-FR', 'ytdFeeBaseAmount', 'YTD Fee Base Amount')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', NULL, 'retainRatePercent', 'Retain rate %')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', 'fr-FR', 'retainRatePercent', 'Taux retenu %')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', NULL, 'retainRateBP', 'Retain rate in BPs')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', 'fr-FR', 'retainRateBP', 'Taux retenu en PB')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', NULL, 'retainRatePercentOf', 'Retain rate % of {0}')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', 'fr-FR', 'retainRatePercentOf', 'Taux retenu % de {0}')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', NULL, 'retainRateBPOf', 'Retain rate in BPs of {0}')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('7D870906-FFC1-4E14-85E0-6837E1F068E8', 'fr-FR', 'retainRateBPOf', 'Taux retenu en PBs de {0}')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'newAgreement', 'new agreement')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'newAgreement', 'nouvelle convention')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'agreement', 'Agreement')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'agreement', 'Convention')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', NULL, 'grid', 'Grid')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', 'fr-FR', 'grid', 'Grille')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', NULL, 'agreement', 'Agreement')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', 'fr-FR', 'agreement', 'Convention')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', NULL, 'newGrid', 'new grid')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', 'fr-FR', 'newGrid', 'nouvelle grille')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', NULL, 'newAgreement', 'new agreement')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('21DB878E-6BF6-4463-BF7B-215C1CFDCCAB', 'fr-FR', 'newAgreement', 'nouvelle convention')


INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E7969FC0-B62C-4B30-AE4A-E1727FF97215', NULL, 'newValue', 'New Value')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E7969FC0-B62C-4B30-AE4A-E1727FF97215', 'fr-FR', 'newValue', 'Nouvelle Valeur')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E7969FC0-B62C-4B30-AE4A-E1727FF97215', NULL, 'currentValue', 'Current Value')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('E7969FC0-B62C-4B30-AE4A-E1727FF97215', 'fr-FR', 'currentValue', 'Valeur Actuelle')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', NULL, 'imageButton_lock_cancel', 'Settlement has been cancelled')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', 'de-DE', 'imageButton_lock_cancel', 'Settlement wurde abgesagt')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', 'fr-FR', 'imageButton_lock_cancel', 'Le versement a été annulé')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', NULL, 'imageButton_lock', 'Settlement has been exported and can only be cancelled')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', 'de-DE', 'imageButton_lock', 'Settlement exportiert wurde und kann nur aufgehoben werden')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('A3384774-1024-4B30-94CD-6BC38EBC247B', 'fr-FR', 'imageButton_lock', 'Le versement a été exporté et peut seulement être annulé')

UPDATE aspnet_local_resources SET resourcevalue = REPLACE(resourcevalue, '<br />', '') where resourcekey = 'ctl00_custPeriodFrom.ErrorMessage'

DELETE FROM aspnet_local_resources WHERE ResourceKey = 'ctl00_custPeriodFrom_Empty'
DELETE FROM aspnet_local_resources WHERE ResourceKey = 'ctl00_custPeriodTo_Empty'
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', NULL, 'ctl00_custPeriodFrom_Empty', 'Please provide "Period to"')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', 'de-DE', 'ctl00_custPeriodFrom_Empty', 'Bitte geben Sie "Periode zu"')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', 'fr-FR', 'ctl00_custPeriodFrom_Empty', 'Champs à remplir "Période à"')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', NULL, 'ctl00_custPeriodTo_Empty', 'Please provide "Period from"')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', 'de-DE', 'ctl00_custPeriodTo_Empty', 'Bitte geben Sie "Zeitraum von"')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('5C1302B3-839E-4F85-997D-3C25CAE9E7CF', 'fr-FR', 'ctl00_custPeriodTo_Empty', 'Champs à remplir "Période du"')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbCV_Title.Text', 'Current Value')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lbCV_Title.Text', 'Valeur Actuelle')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbCV_NewVal.Text', 'New Value')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lbCV_NewVal.Text', 'Nouvelle Valeur')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lblNameGeneric.Text', 'Name')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lblNameGeneric.Text', 'Nom')

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'rfvNameGeneric.ErrorMessage', 'Agreement name is required')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'rfvNameGeneric.ErrorMessage', 'Nom est obligatoire')
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lblAgreementCode.Text', 'Code') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lblAgreementCode.Text', 'Code') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'rfvAgreementCode.ErrorMessage', 'Agreement code is required') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'rfvAgreementCode.ErrorMessage', 'Code est obligatoire') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbErrCodeExists.Text', 'This code is used by another agreement in this convention.') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'lbErrCodeExists.Text', 'Ce code est utilisé par une autre convention') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'cvAgrCode.ErrorMessage', 'Agreement code must be unique within Entity') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', 'fr-FR', 'cvAgrCode.ErrorMessage', 'Le code de la convention doit être unique par Entité') 

INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbAssetMan.Text', 'Entity') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbDirection.Text', 'Direction') 
INSERT aspnet_local_resources (VirtualPathId, CultureCode,ResourceKey, ResourceValue)
VALUES ('BAA611C8-9CD0-447B-A397-0B77676DD902', NULL, 'lbSalReg.Text', 'Sales Region') 

 -- continue with lbAssetMan
 
SELECT * from aspnet_class_names
SELECT * from aspnet_global_resources


delete FROM aspnet_class_names WHERE ClassName = 'Glossary'

-- insert class names
INSERT INTO dbo.aspnet_class_names (ClassName)
    VALUES ('AMS.Framework.Web.UI.WebControls.ExtendedGridViewDecorator')
INSERT INTO dbo.aspnet_class_names (ClassName)
    VALUES ('AMS.Framework.Web.UI.WebControls.GridViewDecorator')
INSERT INTO dbo.aspnet_class_names (ClassName)
    VALUES ('Glossary')
INSERT INTO dbo.aspnet_class_names (ClassName)
VALUES ('ams.usercontrols.FailProofDropDownList')
INSERT INTO dbo.aspnet_class_names (ClassName)
VALUES ('Rcp.Core.Errors')
INSERT INTO dbo.aspnet_class_names (ClassName)
VALUES ('Rcp.Db')

-- insert global resources
DELETE dbo.aspnet_global_resources WHERE ClassNameId = '45FEC3DA-DB07-4CB9-8E05-FD2D3B668225'

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'AmountPositive', 'The amount {0} must be positive')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'AmountPositive', 'Le montant {0} doit être positif')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'AuditTrailInfoAttributeNotInitialized', 'The AuditTrailInfo attribute for class {0} is not set or not initialized')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'AuditTrailInfoAttributeNotInitialized', 'L''attribut AuditTrailInfo pour la classe {0} n''a pas été défini ou initialisé')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'CannotCreateRepository', 'Cannot create the {0} repository')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'CannotCreateRepository', 'Impossible de créer le référentiel {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'DataObjectNull', 'The data object is null')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'DataObjectNull', 'L''objet de donnée n''est pas défini')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'IdPositive', 'The {0} must be greater than zero')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'IdPositive', '{0} doit être plus grand que zéro')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'LocatorNotInitialized', 'Locator has not been initialized')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'LocatorNotInitialized', 'Locator n'' pas été initialisé')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'NotTheSameType', 'Objects need to be of the same type to be compared.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'NotTheSameType', 'Les objets doivent être du même type pour être comparé.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'ServiceLinkedToSubservice', 'It is not possible to delete as there are still sub-services attached.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'ServiceLinkedToSubservice', 'Impossible de supprimer s''il y a des sous-services liés.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'SubserviceLinkedToPayment', 'It is not possible to delete a service or subservice as there are payment linked.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'SubserviceLinkedToPayment', 'Impossible de supprimer un service ou sous-service s''il y a des paiements liés')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'StringEmpty', 'The {0} must not be empty')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'StringEmpty', '{0} ne doit pas être vide')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnitOfWorkIncorrectDispose', 'A transaction of type {0} is being disposed of, but the last open transaction is of type {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnitOfWorkIncorrectDispose', 'Une transaction de type {0} a été terminée, mais la dernière transaction ouverte est de type {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'ValidationNotDone', 'The core class instance has not been validated before accessing the Errors property for {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'ValidationNotDone', 'L''instance de la classe n''a pas été validée avant d''accéder la propriété Errors de {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'ItemWithIdIsNotFound', 'The {0} with id {1} could not be found')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'ItemWithIdIsNotFound', 'L''objet {0} avec l''identifiant {1} n''a pas été trouvé')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'NoFutureDate', '{0} date cannot be in the future')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'NoFutureDate', 'La date {0} ne peut pas être dans le futur')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'MaxNumberDecimal', '{0} number exceeds {1} decimal digits')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'MaxNumberDecimal', 'Le nombre {0} excéde {1} décimale(s)')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'MaxStringLength', '{0} number exceeds {1} decimal digits')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'MaxStringLength', 'La chaîne de caractères {0} excéde {1} caractère(s)')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'StockTransferAlreadyExist', 'There is already a pending transfer in this share class and portfolio.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'StockTransferAlreadyExist', 'Il y a déjà un transfert en cours pour cette combinaison de portefeuille et produit.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'StockTransferLeadsToNegativeStock', 'This transfer will lead to negative stocks')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'StockTransferLeadsToNegativeStock', 'Ce transfert résultera en un stock négatif')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'StockBeingRecalculated', 'The stocks is being recalculated. Please wait until computation is finished.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'StockBeingRecalculated', 'Les stocks sont en cours de recalcul. Veuillez patientez jusqu''à la fin du calcul.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'ExistingInvoicesNotYetExported', '''{0}'' cannot change to ''{1}'' as there are existing invoice(s) not yet exported link to agreement payments')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'ExistingInvoicesNotYetExported', '''{0}'' ne peut pas changer en ''{1}'' puisqu''il y a des factures non exportées existantes liées à des paiements de la convention')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison', '{0} must {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison', '{0} doit {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.EqualTo', 'be equal to {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.EqualTo', 'être égal à {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.NotEqualTo', 'not be equal to {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.NotEqualTo', 'pas être égal à {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.GreaterThan', 'be greater than {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.GreaterThan', 'être plus grand que {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.LessThan', 'be less than {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.LessThan', 'être plus petit que {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.GreaterThanOrEqualTo', 'be greater than or equal to {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.GreaterThanOrEqualTo', 'être plus grand ou égal à {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'UnaryComparison.LessThanOrEqualTo', 'be less than or equal to {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'UnaryComparison.LessThanOrEqualTo', 'être plus petit ou égal à {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison', '{0} must {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison', '{0} doit {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison.Between', 'be between {0} and {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison.Between', 'être entre {0} et {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison.BetweenExcludeBounds', 'be greater than {0} and less than {1}}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison.BetweenExcludeBounds', 'être plus grand que {0} et plus petit que {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison.BetweenExcludeLowerBound', 'be greater than {0} and less than or equal to {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison.BetweenExcludeLowerBound', 'être plus grand que {0} et plus petit ou égal à {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison.BetweenExcludeUpperBound', 'be greater than or equal to {0} and less than {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison.BetweenExcludeUpperBound', 'être plus grand ou égal à {0} et plus petit que {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'BinaryComparison.NotBetween', 'not be between {0} and {1}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'BinaryComparison.NotBetween', 'pas être entre {0} et {1}')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'FeeAlreadyExists', 'This fee already exists')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'FeeAlreadyExists', 'Ce frais existe déjà')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotDeletedWrongStatus', 'Invoice ({0}) cannot be deleted as its workflow status isn''t equal to ''Draft''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotDeletedWrongStatus', 'La facture ({0}) ne peut pas être supprimée puisque son statut n''est pas égal à ''Brouillon''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotDeletedWrongPaymentStatus', 'Invoice ({0}) cannot be deleted as payment workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotDeletedWrongPaymentStatus', 'La facture ({0}) ne peut pas être supprimée puisque le statut du paiement n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotFound', 'No invoice has been found for id : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotFound', 'Aucune facture n''a été trouvée avec l''identifiant : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'NoBalanceLineWithLeftAmount', 'No balance lines has a ''NotInvoiceAmount'' - ''ReadyToBeInvoicedAmount'' != 0 for payment id : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'NoBalanceLineWithLeftAmount', 'Aucune ligne du paiement a ''Montant Non Facturé'' - ''Montant Prêt à être facturé'' != 0 pour le paiement avec l''identifiant : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'PaymentNotFound', 'No payment has been found for id : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'PaymentNotFound', 'Aucun paiement n''a été trouvé avec l''identifiant : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotCreatedWrongPaymentStatus', 'Invoice cannot be created if payment status is different from ''Validated'' for payment id : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotCreatedWrongPaymentStatus', 'La facture ne peut pas être créé si le statut du paiement est différent de ''Valider'' pour le paiement avec l''identifiant : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUpdatedWrongPaymentStatus', 'Invoice cannot be updated if payment status is different from ''Validated'' for payment id : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUpdatedWrongPaymentStatus', 'La facture ne peut pas être mise à jour si le statut du paiement est différent de ''Valider'' pour le paiement avec l''identifiant : {0}')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotValidatedWrongPaymentStatus', 'Invoice ({0}) cannot be validated as payment workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotValidatedWrongPaymentStatus', 'La facture ({0}) ne peut pas être validée puisque le statut du paiement n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotValidatedWrongStatus', 'Invoice ({0}) cannot be validated as its workflow status isn''t equal to ''Draft''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotValidatedWrongStatus', 'La facture ({0}) ne peut pas être validée puisque son status n''est pas égal à ''Brouillon''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotAuthorizedWrongPaymentStatus', 'Invoice ({0}) cannot be authorized as payment workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotAuthorizedWrongPaymentStatus', 'La facture ({0}) ne peut pas être autorisée puisque le statut du paiement n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotAuthorizedWrongStatus', 'Invoice ({0}) cannot be authorized as its workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotAuthorizedWrongStatus', 'La facture ({0}) ne peut pas être autorisée puisque son statut n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotAuthorizedWrongUser', 'Invoice ({0}) cannot be authorised by the same user that validated it.')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotAuthorizedWrongUser', 'La facture ({0}) ne peut pas être autorisée par le même utilisateur qui l''a validée')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnValidatedWrongPaymentStatus', 'Invoice ({0}) cannot be un-validated as payment workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnValidatedWrongPaymentStatus', 'La facture ({0}) ne peut pas être invalidée puisque le statut du paiement n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnValidatedWrongStatus', 'Invoice ({0}) cannot be un-validated as its workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnValidatedWrongStatus', 'La facture ({0}) ne peut pas être invalidée puisque son statut n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnAuthorizedWrongPaymentStatus', 'Invoice ({0}) cannot be un-autorised as payment workflow status isn''t equal to ''Validated''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnAuthorizedWrongPaymentStatus', 'La facture ({0}) ne peut pas être désautorisée puisque le statut du paiement n''est pas égal à ''Valider''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnAuthorizedWrongStatus', 'Invoice ({0}) cannot be un-autorised as its workflow status isn''t equal to ''Authorized''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnAuthorizedWrongStatus', 'La facture ({0}) ne peut pas être désautorisée puisque son statut n''est pas égal à ''Autoriser''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotPaidWrongPaymentStatus', 'Invoice ({0}) cannot be paid as payment workflow status isn''t equal to ''Validated'' or ''Authorized''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotPaidWrongPaymentStatus', 'La facture ({0}) ne peut pas être payée puisque le statut du paiement n''est pas égal à ''Valider'' ou ''Autoriser''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotPaidWrongStatus', 'Invoice ({0}) cannot be paid as its workflow status isn''t equal to ''Exported''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotPaidWrongStatus', 'La facture ({0}) ne peut pas être payée puisque son statut n''est pas égal à ''Exporter''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnPaidWrongPaymentStatus', 'Invoice ({0}) cannot be paid as payment workflow status isn''t equal to ''Validated'' or ''Authorized''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnPaidWrongPaymentStatus', 'La facture ({0}) ne peut pas être payée puisque le statut du paiement n''est pas égal à ''Valider'' ou ''Autoriser''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'InvoiceNotUnPaidWrongStatus', 'Invoice ({0}) cannot be un-paid as its workflow status isn''t equal to ''Paid''')
,('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'InvoiceNotUnPaidWrongStatus', 'La facture ({0}) ne peut pas être impayée puisque son statut n''est pas égal à ''Payer''')


INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'ValueNotExistInValueList', 'Value ({0}) does not exist in valuelist')
    ,('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'ValueNotExistInValueList', 'Valeur ({0}) n''existe pas dans la liste')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_Authorize.ComputationRunningErrorMessage', 'Payment could not be authorised as it is being recalculated. Please wait until computation engine has finished')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_Authorize.ComputationRunningErrorMessage', 'Le paiement ne peut pas être autorisé car il est en train d''être recalculé. Merci d''attendre jusqu''à la fin du calcul.')    
,('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_Authorize.ForceAuthorizationErrorMessage', 'Force authorisation is not permitted for this payment')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_Authorize.ForceAuthorizationErrorMessage', 'Forcer l''autorisation n''est pas permis pour ce paiement')    
,('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_Authorize.AuthorizationErrorMessage', 'The payment cannot be authorized. Check the minimum payment/reinvestment Amount! Check if you are allowed to authorise this payment! (You cannot authorise a payment that you have validated yourself)')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_Authorize.AuthorizationErrorMessage', 'Ce paiement ne peut pas être autorisé. Vérifier le montant minimum de paiement/reinvestissement. Vérifier si vous êtes capable d''autoriser ce paiement. (Vous ne pouvez pas autoriser un paiement que vous avez vous-même validé)')    

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_BulkAuthorize.NotAuthorizeErrorMessage', '<BR>The following payments ({0} of {1}) could not be authorised: ** NOTE: You cannot authorise a payment that you have validated yourself!***{2}')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_BulkAuthorize.NotAuthorizeErrorMessage', '<BR>Les paiements suivants ({0} of {1}) ne peuvent pas être autorisés: ** NOTE: Vous ne pouvez pas autoriser un paiement qui a été validé par vous-même!***{2}')    
,('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_BulkAuthorize.ComputationRunningErrorMessage', '<BR>The following payments ({0} of {1}) could not be authorised as they are being recalculated,{2}')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_BulkAuthorize.ComputationRunningErrorMessage', '<BR>Les paiements suivants ({0} of {1}) ne peuvent pas être autorisés car ils sont en train d''être recalculés,{2}')    
,('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_BulkAuthorize.MinPaymentAmountErrorMessage', '<BR>The total Amount of all affected payments is smaller than the minimum payment amount. ** The payments could not be authorised')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_BulkAuthorize.MinPaymentAmountErrorMessage', '<BR>The montant total de tous les paiements sélectionnés est plus petit que le montant minimum de paiement. ** Les paiements ne peuvent pas être autorisés.')    
,('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_BulkAuthorize.ForceAuthorizationErrorMessage', '<BR>The following payments ({0} of {1}) could not be force authorised as not permitted (Not a negative amount or total amount of all affected payments is greater than or equal to the minimum payment amount).')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_BulkAuthorize.ForceAuthorizationErrorMessage', '<BR>Les paiements suivants ({0} of {1}) ne peuvent pas être forcé car non-permis (le montant est positif ou le montant total de tous les paiements selectionnés est plus grand ou égal au montant minimum de paiement).')    

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue) VALUES
('CE421372-2194-4F26-A751-FF57B337EEFC', NULL, 'Payments_BulkAuthorize.UnKnownErrorMessage', 'An error occured while authorizing the payments. Please check payment instructions for the payments. Also make sure that you are allowed to authorise this payment. You will not be able to authorise it if you validated it.')
,('CE421372-2194-4F26-A751-FF57B337EEFC', 'fr-FR', 'Payments_BulkAuthorize.UnKnownErrorMessage', 'Une erreur s''est produite durant l''autorisation des paiements. Veuillez vérifier que les instructions de paiements, et aussi que vous êtes accrédité pour autoriser ce paiement. Vous ne serez pas capable d''autoriser si vous l''avez validé.')    

    
SELECT dbo.FormatString('<BR>The following payments ({0} of {1}) could not be authorised: ** NOTE: You cannot authorise a payment that you have validated yourself!***{2}', CAST(1 as nvarchar)+','+CAST(2 as nvarchar) + ',' + '3')
'<BR>The following payments ({0} of {1}) could not be authorised as they are being recalculated,{2}' 
'<BR>The total Amount of all affected payments is smaller than the minimum payment amount. ** The payments could not be authorised'
'<BR>The following payments ({0} of {1}) could not be force authorised as not permitted (Not a negative amount or total Amount of all affected payments is greater or equals than the minimum payment amount.'

select dbo.FormatString([dbo].[aspnet_global_resources_selectbykey]('Rcp.Db', 'fr-FR', 'Payments_BulkAuthorize.ComputationRunningErrorMessage', '<BR>The following payments ({0} of {1}) could not be authorised as they are being recalculated,{2}'), CAST(1 as nvarchar) + ',' + CAST(5 as nvarchar) + ',' + '5')  	
    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'IndexNotExistInValueList', 'Index ({0}) does not exist in valuelist')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'IndexNotExistInValueList', 'Index ({0}) n''existe pas dans la liste')
    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'InvalidSelection', 'Selection in dropdownlist {0} is not valid.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'InvalidSelection', 'La sélection dans la liste de valeur {0} est invalide.')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'PleaseSelect', 'Please select')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'PleaseSelect', 'Veuillez sélectionner')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'PleaseSelect', 'Bitte wählen Sie aus')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'All', 'All')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'All', 'Tout')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'All', 'All')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'None', 'None')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'None', 'Aucun')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'None', 'Keine')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'Required', 'Required')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'Required', 'Obligatoire')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'Required', 'Pflichtfeld')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'ValueAlreadyExist', 'Value already exist')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'ValueAlreadyExist', 'Valeur déjà existante')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'ValueAlreadyExist', 'Der Wert existiert bereits')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'ValueNotNumeric', 'Value is not numeric')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'ValueNotNumeric', 'La valeur n''est pas un numérique')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'ValueNotNumeric', 'Der Wert ist nicht numerisch')    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', NULL, 'OneValueRequired', 'You must add at least one value to the list')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'fr-FR', 'OneValueRequired', 'Vous devez sélectionner au moins une valeur dans la liste')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('45FEC3DA-DB07-4CB9-8E05-FD2D3B668225', 'de-DE', 'OneValueRequired', 'Sie müssen der Liste mindestens einen Wert hinzufügen')    



INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', NULL, 'RecordsFound', '{0} records found')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'fr-FR', 'RecordsFound', '{0} résultats')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'de-DE', 'RecordsFound', '{0} datensätze gefunden')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', NULL, 'ValidateInputErrorMessage', 'ExtendedGridViewDecorator: Insert Data Fields cannot be Key Data Fields of the GridView. Please remove the fields {0} from the DataKeyNames property of the GridView.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'fr-FR', 'ValidateInputErrorMessage', 'ExtendedGridViewDecorator: Insérer des champs de données ne peut pas être la clé des champs de données de la GridView. S''il vous plaît supprimer les champs {0} de la propriété DataKeyNames du GridView.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'de-DE', 'ValidateInputErrorMessage', 'ExtendedGridViewDecorator: Einfügen von Datenfeldern kann nicht Schlüsseldatenfelder des Gridview sein. Bitte entfernen Sie die Felder {0} aus der DataKeyNames Eigenschaft des Gridview.')
    
    INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', NULL, 'DefaultDeleteExceptionHandlerErrorMessage', 'Could not delete. This record is referenced elsewhere.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'fr-FR', 'DefaultDeleteExceptionHandlerErrorMessage', 'Impossible de supprimer. Cet enregistrement est référencée ailleurs.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'de-DE', 'DefaultDeleteExceptionHandlerErrorMessage', 'Konnte nicht gelöscht werden. Dieser Datensatz wird an anderer Stelle verwiesen.')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', NULL, 'MissingCreateNewRowEventErrorMessage', 'Cannot create new row for ''{0}'' type. Please handle the ''CreateNewRow'' event.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'fr-FR', 'MissingCreateNewRowEventErrorMessage', 'Vous ne pouvez pas créer de nouvelle ligne pour ''{0}'' de type. S''il vous plaît traiter l''événement ''CreateNewRow.''')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994', 'de-DE', 'MissingCreateNewRowEventErrorMessage', 'Kann neue Zeile erstellen für ''{0}'' Typ. Bitte behandeln Sie die ''CreateNewRow'' Veranstaltung.')


INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'NotFoundColumnErrorMessage', 'Could not find a column with a data field or sort expression = ''{0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'NotFoundColumnErrorMessage', 'Impossible de trouver une colonne avec un champ de données ou trier expression ='' {0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'NotFoundColumnErrorMessage', 'Eine Spalte mit einem Datenfeld konnte nicht gefunden werden oder sortieren Ausdruck ='' {0}''.')
    
    INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'NotFoundDataFieldErrorMessage', 'GetTextValueForDataField: Could not find data field ''{0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'NotFoundDataFieldErrorMessage', 'GetTextValueForDataField: Impossible de trouver le champ de données ''{0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'NotFoundDataFieldErrorMessage', 'GetTextValueForDataField: Konnte keine Datenfeld zu finden ''{0}''.')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'GetControlFromCellControlTypeErrorMessage', 'GridViewDecorator::GetControlFromCell: controlType must be of Control Type')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'GetControlFromCellControlTypeErrorMessage', 'GridViewDecorator::GetControlFromCell: controlType doit être de type de contrôle')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'GetControlFromCellControlTypeErrorMessage', 'GridViewDecorator::GetControlFromCell: control muss der Steuerungstyp sein')
    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'GetControlFromCellControlTypeNotFoundErrorMessage', 'GridViewDecorator::GetControlFromCell: Could not find any control of type ''{0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'GetControlFromCellControlTypeNotFoundErrorMessage', 'GridViewDecorator::GetControlFromCell: Impossible de trouver un contrôle de type ''{0}''.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'GetControlFromCellControlTypeNotFoundErrorMessage', 'GridViewDecorator::GetControlFromCell: Keine Kontrolle von Typ konnte nicht gefunden werden ''{0}''.')
    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'NewRowButtonText', 'Add')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'NewRowButtonText', 'Ajouter')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'NewRowButtonText', 'Hinzufügen')
    
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', NULL, 'BulkButtonText', 'Bulk')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'fr-FR', 'BulkButtonText', 'Ajout multiple')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('2F355C51-1DAF-4FDF-9625-CD10056FA67A', 'de-DE', 'BulkButtonText', 'Mehrere hinzufügen')

INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', NULL, 'CounterPartyAccountingReferenceNameNotNull', 'The field Count. Account.Ref  must contain code and name. Please add the name in the relevant agreement.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'fr-FR', 'CounterPartyAccountingReferenceNameNotNull', 'Le champs Référence Comptable Tiers doit contenir code et nom. Veuillez ajouter le nom au sein de la convention correspondante.')
INSERT INTO dbo.aspnet_global_resources (ClassNameId, CultureCode, ResourceKey, ResourceValue)
    VALUES ('82F9947C-A441-41B5-B9AF-DD81A54F2DC0', 'de-DE', 'CounterPartyAccountingReferenceNameNotNull', 'The field Count. Account.Ref  must contain code and name. Please add the name in the relevant agreement.')

SELECT * FROM dbo.aspnet_global_resources where ResourceKey = 'CounterPartyAccountingReferenceNameNotNull'
--SELECT * FROM aspnet_global_resources


    DELETE aspnet_global_resources
    WHERE ResourceKey='RecordsFound' AND ClassNameId ='CD0BCE53-9CE9-4F0A-A25F-9A5AF8896994'
    
    SELECT * FROM dbo.aspnet_global_resources where ResourceValue LIKE 'Installation'
    UPDATE dbo.aspnet_global_resources SET ResourceValue='Paramètres' WHERE ResourceId='368520CE-0691-4883-BB0A-18803D47265E'


-- Fix menu agreement
BEGIN TRAN
UPDATE aspnet_local_resources
SET ResourceValue = TOLR.ResourceValue
FROM aspnet_local_resources LR
INNER JOIN (
SELECT VP.VirtualPath
     , LR.ResourceId
     , LR.VirtualPathId
      ,LR.ResourceKey
      ,LR.CultureCode
      ,LR.ResourceValue
FROM dbo.aspnet_local_resources AS LR
INNER JOIN dbo.aspnet_virtual_paths AS VP
        ON LR.VirtualPathId = VP.VirtualPathId
WHERE VP.VirtualPath LIKE '~/Site/Pages/Parameterization/Details/AgreementDetails.aspx%'
  AND LR.ResourceKey like '%MenuItem%.Value'
  AND CultureCode IS NULL) AS TOLR
  ON LR.ResourceKey = TOLR.ResourceKey
  AND LR.VirtualPathId = TOLR.VirtualPathId
COMMIT tran