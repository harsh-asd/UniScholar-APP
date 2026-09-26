const { PrismaClient } = require('@prisma/client');
const crypto = require('crypto');
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding Database for MoTA Unified App Demo...');

  // 1. Wipe existing data
  await prisma.scholarshipApplication.deleteMany();
  await prisma.documentWallet.deleteMany();
  await prisma.userOTR.deleteMany();
  await prisma.adminUser.deleteMany();
  console.log('Cleared existing data.');

  // 2. Pre-registered Student OTR Profile
  const hashedKycId = crypto.createHash('sha256').update('123456789012').digest('hex');
  const student = await prisma.userOTR.create({
    data: {
      otrId: '20261234567890',
      maskedKycId: 'XXXXXXXX9012',
      fullName: 'Rahul Meena',
      dob: new Date('2005-06-15'),
      gender: 'Male',
      stStatus: true
    }
  });
  console.log(`Created Student: ${student.fullName} (OTR: ${student.otrId})`);

  // 3. Link DigiLocker Certificates
  await prisma.documentWallet.createMany({
    data: [
      {
        otrId: student.otrId,
        documentType: 'INCOME_CERT',
        digilockerUri: 'dl://cert/income/20261234567890/IN987654',
        isVerified: true
      },
      {
        otrId: student.otrId,
        documentType: 'CASTE_CERT',
        digilockerUri: 'dl://cert/caste/20261234567890/ST123456',
        isVerified: true
      }
    ]
  });
  console.log('Linked DigiLocker certificates.');

  // 4. Sample Applications
  await prisma.scholarshipApplication.create({
    data: {
      otrId: student.otrId,
      schemeName: 'Pre-Matric Scholarship for ST',
      status: 'SUBMITTED'
    }
  });

  await prisma.scholarshipApplication.create({
    data: {
      otrId: student.otrId,
      schemeName: 'Post-Matric Scholarship for ST (Year 1)',
      status: 'L1_APPROVED',
      l1Remarks: 'Valid documents found. Approved.'
    }
  });

  await prisma.scholarshipApplication.create({
    data: {
      otrId: student.otrId,
      schemeName: 'National Fellowship for ST',
      status: 'DISBURSED',
      l1Remarks: 'All verified.',
      l2Remarks: 'Approved for sanction.'
    }
  });
  console.log('Created sample applications (SUBMITTED, L1_APPROVED, DISBURSED).');

  // 5. Admin Credentials
  const passwordHash = crypto.createHash('sha256').update('Admin@123').digest('hex');
  
  await prisma.adminUser.createMany({
    data: [
      {
        email: 'institute@mota.gov.in',
        passwordHash: passwordHash,
        role: 'L1_INSTITUTE',
        assignedInstitutionCode: 'INST-001'
      },
      {
        email: 'district@mota.gov.in',
        passwordHash: passwordHash,
        role: 'L2_DISTRICT',
        assignedInstitutionCode: 'DIST-05'
      }
    ]
  });
  console.log('Created Admin accounts (L1 Institute, L2 District).');

  console.log('Database Seeding Completed Successfully! ✅');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
